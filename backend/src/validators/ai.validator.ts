import { z } from 'zod';

export const aiChatSchema = z.object({
  body: z.object({
    message: z
      .string({ required_error: 'Message is required' })
      .trim()
      .min(1, 'Message cannot be empty')
      .max(1000, 'Message cannot exceed 1000 characters'),
    history: z
      .array(
        z.object({
          role: z.enum(['user', 'assistant', 'model']),
          content: z.string(),
        })
      )
      .optional(),
  }),
});

export const aiRecommendSchema = z.object({
  body: z.object({
    preferences: z
      .string({ required_error: 'Preferences description is required' })
      .trim()
      .min(3, 'Preferences must be at least 3 characters'),
    category: z.string().optional(),
    maxBudget: z.number().min(0).optional(),
  }),
});
