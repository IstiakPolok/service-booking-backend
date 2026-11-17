import { Request, Response } from 'express';
import { AiService } from '../services/ai.service.js';
import { ApiResponse } from '../utils/apiResponse.js';
import { asyncHandler } from '../utils/asyncHandler.js';

export class AiController {
  /**
   * Conversational AI Assistant
   * POST /api/ai/chat
   */
  static chat = asyncHandler(async (req: Request, res: Response) => {
    const { message, history } = req.body;
    const response = await AiService.chat(message, history || []);

    return ApiResponse.success(res, 'AI assistant response generated', response);
  });

  /**
   * Recommendation AI Engine
   * POST /api/ai/recommend
   */
  static recommend = asyncHandler(async (req: Request, res: Response) => {
    const { preferences, category, maxBudget } = req.body;
    const response = await AiService.recommend(preferences, category, maxBudget);

    return ApiResponse.success(res, 'AI recommendations generated', response);
  });
}

