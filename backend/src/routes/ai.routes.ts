import { Router } from 'express';
import { AiController } from '../controllers/ai.controller.js';
import { validate } from '../middlewares/validation.middleware.js';
import { aiChatSchema, aiRecommendSchema } from '../validators/ai.validator.js';

const router = Router();

// AI endpoints can be accessed publicly or with auth context
router.post('/chat', validate(aiChatSchema), AiController.chat);
router.post('/recommend', validate(aiRecommendSchema), AiController.recommend);

export default router;
