import { z } from 'zod';

export const getServicesQuerySchema = z.object({
  query: z.object({
    search: z.string().optional(),
    category: z.string().optional(),
    featured: z.enum(['true', 'false']).optional(),
    minPrice: z.string().regex(/^\d+(\.\d+)?$/, 'minPrice must be a number').optional(),
    maxPrice: z.string().regex(/^\d+(\.\d+)?$/, 'maxPrice must be a number').optional(),
    sortBy: z.enum(['price', 'duration', 'rating', 'name', 'createdAt']).optional(),
    order: z.enum(['asc', 'desc']).optional(),
    page: z.string().regex(/^\d+$/, 'page must be an integer').optional(),
    limit: z.string().regex(/^\d+$/, 'limit must be an integer').optional(),
  }),
});

export const serviceIdParamSchema = z.object({
  params: z.object({
    id: z.string().regex(/^[0-9a-fA-F]{24}$/, 'Invalid service ID format'),
  }),
});

export const createServiceSchema = z.object({
  body: z.object({
    name: z.string({ required_error: 'Service name is required' }).trim().min(3),
    description: z.string({ required_error: 'Description is required' }).trim().min(10),
    price: z.number({ required_error: 'Price is required' }).min(0),
    duration: z.number({ required_error: 'Duration in minutes is required' }).min(5),
    image: z.string({ required_error: 'Image URL is required' }).url('Must be valid URL'),
    category: z.string({ required_error: 'Category is required' }).trim().min(2),
    rating: z.number().min(0).max(5).optional(),
    reviewCount: z.number().min(0).optional(),
    isFeatured: z.boolean().optional(),
    isAvailable: z.boolean().optional(),
  }),
});

export const updateServiceSchema = z.object({
  params: z.object({
    id: z.string().regex(/^[0-9a-fA-F]{24}$/, 'Invalid service ID format'),
  }),
  body: z.object({
    name: z.string().trim().min(3).optional(),
    description: z.string().trim().min(10).optional(),
    price: z.number().min(0).optional(),
    duration: z.number().min(5).optional(),
    image: z.string().url('Must be valid URL').optional(),
    category: z.string().trim().min(2).optional(),
    rating: z.number().min(0).max(5).optional(),
    reviewCount: z.number().min(0).optional(),
    isFeatured: z.boolean().optional(),
    isAvailable: z.boolean().optional(),
  }),
});
