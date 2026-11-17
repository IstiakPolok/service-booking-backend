import { Service, IService } from '../models/service.model.js';
import { ApiError } from '../utils/apiError.js';
import { SERVICE_CATEGORIES } from '../constants/index.js';

export interface ServiceQueryParams {
  search?: string;
  category?: string;
  featured?: string;
  minPrice?: string;
  maxPrice?: string;
  sortBy?: string;
  order?: 'asc' | 'desc';
  page?: string;
  limit?: string;
}

export class ServiceService {
  /**
   * Get all services with search, filtering, sorting, and pagination
   */
  static async getServices(query: ServiceQueryParams) {
    const page = parseInt(query.page || '1', 10);
    const limit = parseInt(query.limit || '10', 10);
    const skip = (page - 1) * limit;

    const filter: any = { isAvailable: true };

    // Search query across name and description
    if (query.search) {
      filter.$or = [
        { name: { $regex: query.search, $options: 'i' } },
        { description: { $regex: query.search, $options: 'i' } },
        { category: { $regex: query.search, $options: 'i' } },
      ];
    }

    // Filter by Category
    if (query.category && query.category.toLowerCase() !== 'all') {
      filter.category = { $regex: new RegExp(`^${query.category}$`, 'i') };
    }

    // Filter by Featured
    if (query.featured !== undefined) {
      filter.isFeatured = query.featured === 'true';
    }

    // Filter by Price range
    if (query.minPrice !== undefined || query.maxPrice !== undefined) {
      filter.price = {};
      if (query.minPrice !== undefined) filter.price.$gte = parseFloat(query.minPrice);
      if (query.maxPrice !== undefined) filter.price.$lte = parseFloat(query.maxPrice);
    }

    // Sorting
    const sortField = query.sortBy || 'createdAt';
    const sortOrder = query.order === 'asc' ? 1 : -1;
    const sort: any = { [sortField]: sortOrder };

    const [services, total] = await Promise.all([
      Service.find(filter).sort(sort).skip(skip).limit(limit),
      Service.countDocuments(filter),
    ]);

    const totalPages = Math.ceil(total / limit) || 1;

    return {
      services,
      meta: {
        total,
        page,
        limit,
        totalPages,
        hasNextPage: page < totalPages,
        hasPrevPage: page > 1,
      },
    };
  }

  /**
   * Get featured services (for home screen carousel/highlights)
   */
  static async getFeaturedServices(limit = 6): Promise<IService[]> {
    return Service.find({ isFeatured: true, isAvailable: true }).limit(limit).sort({ rating: -1 });
  }

  /**
   * Get service by ID
   */
  static async getServiceById(id: string): Promise<IService> {
    const service = await Service.findById(id);
    if (!service) {
      throw ApiError.notFound(`Service with ID ${id} not found`);
    }
    return service;
  }

  /**
   * Get all service categories with service count
   */
  static async getCategories(): Promise<{ name: string; count: number }[]> {
    const counts = await Service.aggregate([
      { $match: { isAvailable: true } },
      { $group: { _id: '$category', count: { $sum: 1 } } },
      { $project: { name: '$_id', count: 1, _id: 0 } },
      { $sort: { count: -1 } },
    ]);

    return counts;
  }

  /**
   * Create new service
   */
  static async createService(data: Partial<IService>): Promise<IService> {
    return Service.create(data);
  }

  /**
   * Update service
   */
  static async updateService(id: string, data: Partial<IService>): Promise<IService> {
    const service = await Service.findByIdAndUpdate(
      id,
      { $set: data },
      { new: true, runValidators: true }
    );
    if (!service) {
      throw ApiError.notFound(`Service with ID ${id} not found`);
    }
    return service;
  }

  /**
   * Delete or soft-delete service
   */
  static async deleteService(id: string): Promise<void> {
    const service = await Service.findByIdAndUpdate(id, { $set: { isAvailable: false } });
    if (!service) {
      throw ApiError.notFound(`Service with ID ${id} not found`);
    }
  }
}
