export enum AppointmentStatus {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  CANCELLED = 'CANCELLED',
  COMPLETED = 'COMPLETED',
}

export enum UserRole {
  USER = 'user',
  ADMIN = 'admin',
}

export const SERVICE_CATEGORIES = [
  'Hair & Styling',
  'Spa & Massage',
  'Skin & Beauty',
  'Dental Care',
  'Fitness & Wellness',
  'Home Cleaning',
  'Appliance Repair',
] as const;

export type ServiceCategory = (typeof SERVICE_CATEGORIES)[number];

export const STANDARD_TIME_SLOTS = [
  '09:00 AM - 10:00 AM',
  '10:00 AM - 11:00 AM',
  '11:00 AM - 12:00 PM',
  '12:00 PM - 01:00 PM',
  '02:00 PM - 03:00 PM',
  '03:00 PM - 04:00 PM',
  '04:00 PM - 05:00 PM',
  '05:00 PM - 06:00 PM',
] as const;

export type TimeSlot = (typeof STANDARD_TIME_SLOTS)[number];

