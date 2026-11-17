import { Appointment, IAppointment } from '../models/appointment.model.js';
import { Service } from '../models/service.model.js';
import { ApiError } from '../utils/apiError.js';
import { AppointmentStatus, STANDARD_TIME_SLOTS } from '../constants/index.js';

export interface CreateAppointmentInput {
  userId: string;
  serviceId: string;
  date: string; // "YYYY-MM-DD"
  timeSlot: string;
  notes?: string;
}

export class AppointmentService {
  /**
   * Helper: Get current date in "YYYY-MM-DD" format
   */
  private static getTodayDateString(): string {
    const today = new Date();
    return today.toISOString().split('T')[0];
  }

  /**
   * Create a new appointment with strict availability validation
   */
  static async createAppointment(input: CreateAppointmentInput): Promise<IAppointment> {
    const { userId, serviceId, date, timeSlot, notes } = input;

    // 1. Verify service existence and availability
    const service = await Service.findById(serviceId);
    if (!service || !service.isAvailable) {
      throw ApiError.notFound('Selected service does not exist or is currently unavailable');
    }

    // 2. Validate appointment date is not in the past
    const todayStr = this.getTodayDateString();
    if (date < todayStr) {
      throw ApiError.badRequest('Cannot book an appointment for a past date');
    }

    // 3. Prevent double booking / conflicting appointments for the same service and slot
    const existingServiceBooking = await Appointment.findOne({
      service: serviceId,
      date,
      timeSlot,
      status: { $in: [AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED] },
    });

    if (existingServiceBooking) {
      throw ApiError.conflict(
        `The time slot "${timeSlot}" on ${date} is already booked. Please choose another time slot.`
      );
    }

    // 4. Prevent the user from booking two appointments at the exact same time slot
    const existingUserBooking = await Appointment.findOne({
      user: userId,
      date,
      timeSlot,
      status: { $in: [AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED] },
    });

    if (existingUserBooking) {
      throw ApiError.conflict(
        `You already have an appointment scheduled for "${timeSlot}" on ${date}.`
      );
    }

    // 5. Create appointment
    const appointment = await Appointment.create({
      user: userId,
      service: serviceId,
      date,
      timeSlot,
      notes: notes || '',
      totalAmount: service.price,
      status: AppointmentStatus.PENDING,
    });

    // Populate service and user details for response
    await appointment.populate([
      { path: 'service', select: 'name price duration image category' },
      { path: 'user', select: 'name email phone' },
    ]);

    return appointment;
  }

  /**
   * Get available time slots for a specific service on a given date
   */
  static async getAvailableSlots(
    serviceId: string,
    date: string
  ): Promise<{ date: string; slots: { timeSlot: string; isAvailable: boolean }[] }> {
    const service = await Service.findById(serviceId);
    if (!service) {
      throw ApiError.notFound('Service not found');
    }

    // Find all active bookings on this date for this service
    const activeBookings = await Appointment.find({
      service: serviceId,
      date,
      status: { $in: [AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED] },
    }).select('timeSlot');

    const bookedSlotsSet = new Set(activeBookings.map((b) => b.timeSlot));

    const todayStr = this.getTodayDateString();
    const isPastDate = date < todayStr;

    const slots = STANDARD_TIME_SLOTS.map((slot) => {
      let isAvailable = !bookedSlotsSet.has(slot);
      if (isPastDate) {
        isAvailable = false;
      }
      return {
        timeSlot: slot,
        isAvailable,
      };
    });

    return {
      date,
      slots,
    };
  }

  /**
   * Retrieve appointments belonging to the authenticated user
   */
  static async getUserAppointments(
    userId: string,
    filter?: 'upcoming' | 'previous' | 'all',
    status?: AppointmentStatus,
    page = 1,
    limit = 10
  ) {
    const skip = (page - 1) * limit;
    const query: any = { user: userId };
    const todayStr = this.getTodayDateString();

    if (status) {
      query.status = status;
    }

    if (filter === 'upcoming') {
      query.date = { $gte: todayStr };
      if (!status) {
        query.status = { $in: [AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED] };
      }
    } else if (filter === 'previous') {
      query.$or = [
        { date: { $lt: todayStr } },
        { status: { $in: [AppointmentStatus.COMPLETED, AppointmentStatus.CANCELLED] } },
      ];
    }

    const sortOrder: any = filter === 'upcoming' ? { date: 1, timeSlot: 1 } : { date: -1, createdAt: -1 };

    const [appointments, total] = await Promise.all([
      Appointment.find(query)
        .populate('service', 'name price duration image category')
        .sort(sortOrder)
        .skip(skip)
        .limit(limit),
      Appointment.countDocuments(query),
    ]);

    const totalPages = Math.ceil(total / limit) || 1;

    return {
      appointments,
      meta: {
        total,
        page,
        limit,
        totalPages,
      },
    };
  }

  /**
   * Retrieve individual appointment details
   */
  static async getAppointmentById(
    appointmentId: string,
    userId: string,
    isAdmin = false
  ): Promise<IAppointment> {
    const query: any = { _id: appointmentId };
    if (!isAdmin) {
      query.user = userId;
    }

    const appointment = await Appointment.findOne(query).populate([
      { path: 'service' },
      { path: 'user', select: 'name email phone avatar' },
    ]);

    if (!appointment) {
      throw ApiError.notFound('Appointment not found or you do not have permission to view it');
    }

    return appointment;
  }

  /**
   * Cancel an appointment
   */
  static async cancelAppointment(appointmentId: string, userId: string): Promise<IAppointment> {
    const appointment = await Appointment.findOne({ _id: appointmentId, user: userId });
    if (!appointment) {
      throw ApiError.notFound('Appointment not found');
    }

    if (appointment.status === AppointmentStatus.CANCELLED) {
      throw ApiError.badRequest('This appointment is already cancelled');
    }

    if (appointment.status === AppointmentStatus.COMPLETED) {
      throw ApiError.badRequest('Cannot cancel a completed appointment');
    }

    appointment.status = AppointmentStatus.CANCELLED;
    await appointment.save();

    await appointment.populate([
      { path: 'service', select: 'name price duration image category' },
      { path: 'user', select: 'name email phone' },
    ]);

    return appointment;
  }
}
