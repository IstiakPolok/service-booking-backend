import { Router } from 'express';
import { ServiceController } from '../controllers/service.controller.js';
import { authenticate, requireAdmin } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';
import {
  getServicesQuerySchema,
  serviceIdParamSchema,
  createServiceSchema,
  updateServiceSchema,
} from '../validators/service.validator.js';

const router = Router();

// Public routes
router.get('/', validate(getServicesQuerySchema), ServiceController.getServices);
router.get('/featured', ServiceController.getFeatured);
router.get('/categories', ServiceController.getCategories);
router.get('/:id', validate(serviceIdParamSchema), ServiceController.getServiceById);

// Admin-protected routes
router.post('/', authenticate, requireAdmin, validate(createServiceSchema), ServiceController.createService);
router.put('/:id', authenticate, requireAdmin, validate(updateServiceSchema), ServiceController.updateService);
router.delete('/:id', authenticate, requireAdmin, validate(serviceIdParamSchema), ServiceController.deleteService);

export default router;

