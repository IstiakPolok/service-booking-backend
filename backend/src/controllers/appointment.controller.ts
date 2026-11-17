import { Request, Response } from 'express';
import { AppointmentService } from '../services/appointment.service.js';
import { ApiResponse } from '../utils/apiResponse.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { ApiError } from '../utils/apiError.js';
import { AppointmentStatus, UserRole } from '../constants/index.js';

export class AppointmentController {
  /**
   * Create new appointment booking
   * POST /api/appointments
   */
  static createAppointment = asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) {
      throw ApiError.unauthorized();
    }

    const { serviceId, date, timeSlot, notes } = req.body;
    const appointment = await AppointmentService.createAppointment({
      userId: req.user.id,
      serviceId,
      date,
      timeSlot,
      notes,
    });

    return ApiResponse.created(res, 'Appointment booked successfully', appointment);
  });

  /**
   * Get user appointments (upcoming, previous, or all)
   * GET /api/appointments
   */
  static getUserAppointments = asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) {
      throw ApiError.unauthorized();
    }

    const { filter, status, page, limit } = req.query;
    const result = await AppointmentService.getUserAppointments(
      req.user.id,
      filter as 'upcoming' | 'previous' | 'all',
      status as AppointmentStatus,
      page ? parseInt(page as string, 10) : 1,
      limit ? parseInt(limit as string, 10) : 10
    );

    return ApiResponse.success(
      res,
      'Appointments retrieved successfully',
      result.appointments,
      result.meta
    );
  });

  /**
   * Get available time slots for a service on a given date
   * GET /api/appointments/available-slots
   */
  static getAvailableSlots = asyncHandler(async (req: Request, res: Response) => {
    const { serviceId, date } = req.query as { serviceId: string; date: string };
    const result = await AppointmentService.getAvailableSlots(serviceId, date);
    return ApiResponse.success(res, 'Available time slots retrieved successfully', result);
  });

  /**
   * Get individual appointment by ID
   * GET /api/appointments/:id
   */
  static getAppointmentById = asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) {
      throw ApiError.unauthorized();
    }

    const isAdmin = req.user.role === UserRole.ADMIN;
    const appointment = await AppointmentService.getAppointmentById(
      req.params.id,
      req.user.id,
      isAdmin
    );

    return ApiResponse.success(res, 'Appointment details retrieved successfully', appointment);
  });

  /**
   * Cancel appointment
   * PATCH /api/appointments/:id/cancel
   */
  static cancelAppointment = asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) {
      throw ApiError.unauthorized();
    }

    const appointment = await AppointmentService.cancelAppointment(
      req.params.id,
      req.user.id
    );

    return ApiResponse.success(res, 'Appointment cancelled successfully', appointment);
  });
}

