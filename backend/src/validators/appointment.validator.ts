import { z } from 'zod';
import { AppointmentStatus } from '../constants/index.js';

export const createAppointmentSchema = z.object({
  body: z.object({
    serviceId: z
      .string({ required_error: 'Service ID is required' })
      .regex(/^[0-9a-fA-F]{24}$/, 'Invalid service ID format'),
    date: z
      .string({ required_error: 'Date is required' })
      .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in format YYYY-MM-DD'),
    timeSlot: z
      .string({ required_error: 'Time slot is required' })
      .min(3, 'Time slot must be provided'),
    notes: z.string().max(500, 'Notes cannot exceed 500 characters').optional(),
  }),
});

export const getAppointmentsQuerySchema = z.object({
  query: z.object({
    status: z.nativeEnum(AppointmentStatus).optional(),
    filter: z.enum(['upcoming', 'previous', 'all']).optional(),
    page: z.string().regex(/^\d+$/, 'page must be an integer').optional(),
    limit: z.string().regex(/^\d+$/, 'limit must be an integer').optional(),
  }),
});

export const appointmentIdParamSchema = z.object({
  params: z.object({
    id: z.string().regex(/^[0-9a-fA-F]{24}$/, 'Invalid appointment ID format'),
  }),
});

export const availableSlotsQuerySchema = z.object({
  query: z.object({
    serviceId: z
      .string({ required_error: 'Service ID is required' })
      .regex(/^[0-9a-fA-F]{24}$/, 'Invalid service ID format'),
    date: z
      .string({ required_error: 'Date is required' })
      .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in format YYYY-MM-DD'),
  }),
});

