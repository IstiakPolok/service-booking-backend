import { Router } from 'express';
import { AppointmentController } from '../controllers/appointment.controller.js';
import { authenticate } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';
import {
  createAppointmentSchema,
  getAppointmentsQuerySchema,
  appointmentIdParamSchema,
  availableSlotsQuerySchema,
} from '../validators/appointment.validator.js';

const router = Router();

// Public / Protected helper route for checking slot availability
router.get('/available-slots', validate(availableSlotsQuerySchema), AppointmentController.getAvailableSlots);

// Protected routes (User must be logged in)
router.use(authenticate);

router.post('/', validate(createAppointmentSchema), AppointmentController.createAppointment);
router.get('/', validate(getAppointmentsQuerySchema), AppointmentController.getUserAppointments);
router.get('/:id', validate(appointmentIdParamSchema), AppointmentController.getAppointmentById);
router.patch('/:id/cancel', validate(appointmentIdParamSchema), AppointmentController.cancelAppointment);

export default router;
