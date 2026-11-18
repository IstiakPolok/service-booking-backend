import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller.js';
import { validate } from '../middlewares/validation.middleware.js';
import { authenticate } from '../middlewares/auth.middleware.js';
import { authRateLimiter } from '../middlewares/rateLimiter.js';
import { uploadAvatar } from '../middlewares/upload.middleware.js';
import {
  registerSchema,
  loginSchema,
  changePasswordSchema,
} from '../validators/auth.validator.js';

const router = Router();

// Public routes
router.post(
  '/register',
  authRateLimiter,
  uploadAvatar.single('avatar'),
  validate(registerSchema),
  AuthController.register
);
router.post('/login', authRateLimiter, validate(loginSchema), AuthController.login);
router.post('/logout', AuthController.logout);

// Protected routes
router.get('/me', authenticate, AuthController.getMe);
router.put('/change-password', authenticate, validate(changePasswordSchema), AuthController.changePassword);

export default router;

