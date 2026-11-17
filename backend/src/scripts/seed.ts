import mongoose from 'mongoose';
import { User } from '../models/user.model.js';
import { Service } from '../models/service.model.js';
import { Appointment } from '../models/appointment.model.js';
import { AppointmentStatus, UserRole } from '../constants/index.js';
import { logger } from '../utils/logger.js';
import { connectDatabase, disconnectDatabase } from '../config/database.js';

export const seedServicesData = [
  {
    name: 'Executive Haircut & Styling',
    description: 'Precision haircut, invigorating shampoo wash, scalp massage, and custom blow-dry styling tailored to your facial structure.',
    price: 35.0,
    duration: 45,
    image: 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?auto=format&fit=crop&w=800&q=80',
    category: 'Hair & Styling',
    rating: 4.9,
    reviewCount: 88,
    isFeatured: true,
    isAvailable: true,
  },
  {
    name: 'Deep Tissue Therapeutic Massage',
    description: 'Relieves chronic muscle tension and knots using slow strokes and deep finger pressure on contracted areas.',
    price: 80.0,
    duration: 60,
    image: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=800&q=80',
    category: 'Spa & Massage',
    rating: 4.95,
    reviewCount: 142,
    isFeatured: true,
    isAvailable: true,
  },
  {
    name: 'Swedish Relaxation Massage',
    description: 'Gentle, full-body Swedish massage designed to relax muscles, boost circulation, and calm your nervous system.',
    price: 65.0,
    duration: 60,
    image: 'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?auto=format&fit=crop&w=800&q=80',
    category: 'Spa & Massage',
    rating: 4.8,
    reviewCount: 96,
    isFeatured: false,
    isAvailable: true,
  },
  {
    name: 'Hydrating Glow Facial',
    description: 'Deep pore cleansing, gentle exfoliation, steam treatment, and botanical hyaluronic acid hydration mask.',
    price: 55.0,
    duration: 50,
    image: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=800&q=80',
    category: 'Skin & Beauty',
    rating: 4.85,
    reviewCount: 64,
    isFeatured: true,
    isAvailable: true,
  },
  {
    name: 'Anti-Aging Collagen Facial',
    description: 'Targeted micro-current lift, vitamin C infusion, and collagen-boosting peptide therapy for youthful skin.',
    price: 75.0,
    duration: 60,
    image: 'https://images.unsplash.com/photo-1512290900672-1f02e6a0d24e?auto=format&fit=crop&w=800&q=80',
    category: 'Skin & Beauty',
    rating: 4.75,
    reviewCount: 45,
    isFeatured: false,
    isAvailable: true,
  },
  {
    name: 'Professional Teeth Whitening',
    description: 'Advanced dental LED laser whitening session removing tough stains and lightening teeth by up to 5 shades.',
    price: 120.0,
    duration: 60,
    image: 'https://images.unsplash.com/photo-1606811841689-23dfddce3e95?auto=format&fit=crop&w=800&q=80',
    category: 'Dental Care',
    rating: 4.9,
    reviewCount: 110,
    isFeatured: true,
    isAvailable: true,
  },
  {
    name: 'Comprehensive Dental Checkup & Cleaning',
    description: 'Full oral exam, plaque scaling, ultrasonic polishing, and personalized preventive care guidance.',
    price: 60.0,
    duration: 45,
    image: 'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?auto=format&fit=crop&w=800&q=80',
    category: 'Dental Care',
    rating: 4.8,
    reviewCount: 78,
    isFeatured: false,
    isAvailable: true,
  },
  {
    name: '1-on-1 Personal Fitness Coaching',
    description: 'Private 60-minute training session covering form correction, strength conditioning, and nutrition assessment.',
    price: 50.0,
    duration: 60,
    image: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=800&q=80',
    category: 'Fitness & Wellness',
    rating: 4.88,
    reviewCount: 52,
    isFeatured: true,
    isAvailable: true,
  },
  {
    name: 'Premium Deep Home Cleaning',
    description: 'Thorough top-to-bottom sanitize of living room, kitchen, bathrooms, and bedrooms by certified professionals.',
    price: 95.0,
    duration: 120,
    image: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80',
    category: 'Home Cleaning',
    rating: 4.82,
    reviewCount: 130,
    isFeatured: true,
    isAvailable: true,
  },
  {
    name: 'Air Conditioner Service & Filter Clean',
    description: 'Complete inspection, condenser coil wash, refrigerant level check, and anti-bacterial filter sanitation.',
    price: 45.0,
    duration: 60,
    image: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=800&q=80',
    category: 'Appliance Repair',
    rating: 4.79,
    reviewCount: 89,
    isFeatured: false,
    isAvailable: true,
  },
];

export const autoSeedIfEmpty = async (): Promise<void> => {
  const serviceCount = await Service.countDocuments();
  if (serviceCount > 0) {
    logger.info('Database already contains services. Skipping auto-seed.');
    return;
  }

  logger.info('Database is empty. Populating initial seed data...');

  // Create Users
  const user = await User.create({
    name: 'John Doe',
    email: 'john.doe@example.com',
    password: 'Password123!',
    phone: '+1 555-0199',
    avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
    role: UserRole.USER,
  });

  await User.create({
    name: 'Admin Manager',
    email: 'admin@example.com',
    password: 'Password123!',
    phone: '+1 555-0100',
    role: UserRole.ADMIN,
  });

  // Create Services
  const createdServices = await Service.insertMany(seedServicesData);
  logger.success(`Seeded ${createdServices.length} services successfully.`);

  // Create Sample Appointments
  const today = new Date();
  const tomorrow = new Date(today);
  tomorrow.setDate(tomorrow.getDate() + 1);
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);

  const formatDate = (d: Date) => d.toISOString().split('T')[0];

  await Appointment.create([
    {
      user: user._id,
      service: createdServices[0]._id,
      date: formatDate(tomorrow),
      timeSlot: '10:00 AM - 11:00 AM',
      status: AppointmentStatus.CONFIRMED,
      notes: 'Please keep sides short and textured on top.',
      totalAmount: createdServices[0].price,
    },
    {
      user: user._id,
      service: createdServices[1]._id,
      date: formatDate(yesterday),
      timeSlot: '02:00 PM - 03:00 PM',
      status: AppointmentStatus.COMPLETED,
      notes: 'Focus on shoulder and lower back tension.',
      totalAmount: createdServices[1].price,
    },
  ]);

  logger.success('Sample appointments created successfully.');
};

// Standalone runner for `npm run seed`
const runStandaloneSeed = async () => {
  try {
    await connectDatabase();
    logger.info('Clearing old collections for clean seed...');
    await Promise.all([
      User.deleteMany({}),
      Service.deleteMany({}),
      Appointment.deleteMany({}),
    ]);
    await autoSeedIfEmpty();
    logger.success('Seeding completed successfully!');
  } catch (err: any) {
    logger.error('Error during seeding:', err);
  } finally {
    await disconnectDatabase();
    process.exit(0);
  }
};

// Check if file is being executed directly
if (process.argv[1]?.includes('seed')) {
  runStandaloneSeed();
}
