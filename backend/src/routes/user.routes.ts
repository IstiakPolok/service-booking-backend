import { Router } from 'express';
import { UserController } from '../controllers/user.controller.js';
import { authenticate } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';
import { updateProfileSchema } from '../validators/auth.validator.js';
import { uploadAvatar } from '../middlewares/upload.middleware.js';

const router = Router();

// All user routes require authentication
router.use(authenticate);

router.get('/profile', UserController.getProfile);
router.put('/profile', validate(updateProfileSchema), UserController.updateProfile);
router.post('/avatar', uploadAvatar.single('avatar'), UserController.uploadAvatar);

export default router;

