import { GoogleGenerativeAI } from '@google/generative-ai';
import { Service, IService } from '../models/service.model.js';
import { ENV } from '../config/env.js';
import { logger } from '../utils/logger.js';

export interface ChatMessage {
  role: 'user' | 'assistant' | 'model';
  content: string;
}

export interface AiResponse {
  reply: string;
  suggestedServices: IService[];
  provider: 'gemini' | 'rule_engine';
}

export class AiService {
  private static geminiClient: GoogleGenerativeAI | null = null;

  private static getGemini(): GoogleGenerativeAI | null {
    if (!this.geminiClient && ENV.GEMINI_API_KEY) {
      this.geminiClient = new GoogleGenerativeAI(ENV.GEMINI_API_KEY);
    }
    return this.geminiClient;
  }

  /**
   * Builds the grounding catalog context string from the database services
   */
  private static buildCatalogContext(services: IService[]): string {
    const list = services.map(
      (s, index) =>
        `${index + 1}. [ID: ${s._id}] "${s.name}" | Category: ${s.category} | Price: $${s.price} | Duration: ${s.duration} mins | Rating: ${s.rating}★\n   Description: ${s.description}`
    );
    return list.join('\n\n');
  }

  /**
   * Chat endpoint for user questions and service inquiries
   */
  static async chat(message: string, history: ChatMessage[] = []): Promise<AiResponse> {
    const services = await Service.find({ isAvailable: true });
    const gemini = this.getGemini();

    if (gemini) {
      try {
        const catalogContext = this.buildCatalogContext(services);

        const systemPrompt = `You are the friendly, intelligent AI Booking Assistant for our Service Booking & Management platform.
Your job is to:
1. Help users discover the perfect service for their needs.
2. Answer questions about service prices, durations, procedures, and preparation.
3. Provide recommendations based on their budget, schedule, or specific goals.
4. Encourage them to book an appointment.

Here is our live service catalog from the database:
${catalogContext}

Instructions:
- ONLY recommend services that exist in the catalog above.
- Mention the service name, price, and duration clearly.
- If recommending a service, include its name exactly as shown.
- Keep your tone warm, professional, helpful, and concise (ideal for a mobile screen).
- If asked something unrelated to our services, gently redirect them back to our available services.`;

        const model = gemini.getGenerativeModel({
          model: 'gemini-1.5-flash',
          systemInstruction: systemPrompt,
        });

        // Format history for Gemini SDK
        const geminiHistory = history.map((h) => ({
          role: h.role === 'assistant' ? 'model' : 'user',
          parts: [{ text: h.content }],
        }));

        const chatSession = model.startChat({
          history: geminiHistory,
        });

        const result = await chatSession.sendMessage(message);
        const replyText = result.response.text();

        // Extract any services mentioned in the AI reply
        const suggested = services.filter((s) =>
          replyText.toLowerCase().includes(s.name.toLowerCase())
        );

        return {
          reply: replyText,
          suggestedServices: suggested.slice(0, 3),
          provider: 'gemini',
        };
      } catch (err: any) {
        logger.warn(`Gemini API call failed, falling back to smart engine: ${err.message}`);
      }
    }

    // Fallback: Smart Knowledge-Grounded Assistant Engine
    return this.smartRuleEngine(message, services);
  }

  /**
   * Targeted recommendation endpoint based on user criteria
   */
  static async recommend(
    preferences: string,
    category?: string,
    maxBudget?: number
  ): Promise<AiResponse> {
    let query: any = { isAvailable: true };

    if (category && category.toLowerCase() !== 'all') {
      query.category = { $regex: new RegExp(`^${category}$`, 'i') };
    }

    if (maxBudget !== undefined && maxBudget > 0) {
      query.price = { $lte: maxBudget };
    }

    let matchingServices = await Service.find(query).sort({ rating: -1, price: 1 });

    const lowerPref = preferences.toLowerCase();
    // Re-rank based on keyword match
    if (lowerPref) {
      matchingServices = matchingServices.sort((a, b) => {
        const scoreA = (lowerPref.includes(a.name.toLowerCase()) ? 2 : 0) +
          (lowerPref.includes(a.category.toLowerCase()) ? 1 : 0);
        const scoreB = (lowerPref.includes(b.name.toLowerCase()) ? 2 : 0) +
          (lowerPref.includes(b.category.toLowerCase()) ? 1 : 0);
        return scoreB - scoreA;
      });
    }

    const topPicks = matchingServices.slice(0, 3);

    let reply = '';
    if (topPicks.length === 0) {
      reply = `I couldn't find any services matching "${preferences}" within your criteria. Please try adjusting your budget or category!`;
    } else {
      reply = `Based on your request "${preferences}", here are my top recommended services for you:\n\n` +
        topPicks
          .map(
            (s) =>
              `• **${s.name}** (${s.category}) - $${s.price} (${s.duration} mins) - ${s.rating}★ rating. ${s.description}`
          )
          .join('\n\n') +
        `\n\nWould you like to book one of these now?`;
    }

    return {
      reply,
      suggestedServices: topPicks,
      provider: ENV.GEMINI_API_KEY ? 'gemini' : 'rule_engine',
    };
  }

  /**
   * Rule-based grounded assistant fallback engine (Active if no Gemini API key is configured)
   */
  private static smartRuleEngine(message: string, services: IService[]): AiResponse {
    const lower = message.toLowerCase();

    // Check budget mentions (e.g. "under 50", "below $100", "cheap")
    const budgetMatch = lower.match(/(?:under|below|less than|\$)\s*(\d+)/);
    let budgetLimit: number | null = budgetMatch ? parseFloat(budgetMatch[1]) : null;

    // Check category keywords
    let matchedCategoryServices: IService[] = [];
    if (lower.includes('hair') || lower.includes('cut') || lower.includes('style')) {
      matchedCategoryServices = services.filter((s) => s.category.toLowerCase().includes('hair'));
    } else if (lower.includes('massage') || lower.includes('spa') || lower.includes('relax') || lower.includes('stress')) {
      matchedCategoryServices = services.filter((s) => s.category.toLowerCase().includes('spa') || s.category.toLowerCase().includes('massage'));
    } else if (lower.includes('skin') || lower.includes('facial') || lower.includes('beauty')) {
      matchedCategoryServices = services.filter((s) => s.category.toLowerCase().includes('skin') || s.category.toLowerCase().includes('beauty'));
    } else if (lower.includes('dental') || lower.includes('teeth') || lower.includes('tooth')) {
      matchedCategoryServices = services.filter((s) => s.category.toLowerCase().includes('dental'));
    } else if (lower.includes('fitness') || lower.includes('workout') || lower.includes('gym')) {
      matchedCategoryServices = services.filter((s) => s.category.toLowerCase().includes('fitness'));
    } else if (lower.includes('clean') || lower.includes('house') || lower.includes('home')) {
      matchedCategoryServices = services.filter((s) => s.category.toLowerCase().includes('clean'));
    } else if (lower.includes('repair') || lower.includes('appliance') || lower.includes('fix')) {
      matchedCategoryServices = services.filter((s) => s.category.toLowerCase().includes('repair'));
    }

    let candidates = matchedCategoryServices.length > 0 ? matchedCategoryServices : services;

    if (budgetLimit !== null) {
      candidates = candidates.filter((s) => s.price <= budgetLimit!);
    }

    // Featured / popular check
    if (lower.includes('popular') || lower.includes('featured') || lower.includes('best')) {
      candidates = candidates.filter((s) => s.isFeatured || s.rating >= 4.8);
    }

    const picks = candidates.slice(0, 3);

    let reply = '';
    if (lower.includes('hello') || lower.includes('hi') || lower.includes('hey')) {
      reply = `Hello! I'm your AI Booking Assistant. I can help you find services, compare prices and durations, or recommend the best appointments for your schedule. What are you looking for today?`;
    } else if (picks.length > 0) {
      reply = `Here are great options that match what you're looking for:\n\n` +
        picks
          .map((s) => `• **${s.name}** ($${s.price}, ${s.duration} mins): ${s.description}`)
          .join('\n\n') +
        `\n\nYou can select any of these services to view open time slots and book immediately!`;
    } else {
      reply = `We have a wide range of services including Hair & Styling, Spa & Massage, Dental Care, Fitness, and Home Services. Could you tell me more about what you need or your preferred budget?`;
    }

    return {
      reply,
      suggestedServices: picks,
      provider: 'rule_engine',
    };
  }
}
