import { Request, Response } from 'express';
import { ServiceService } from '../services/service.service.js';
import { ApiResponse } from '../utils/apiResponse.js';
import { asyncHandler } from '../utils/asyncHandler.js';

export class ServiceController {
  /**
   * Get all services with search, filtering, and pagination
   * GET /api/services
   */
  static getServices = asyncHandler(async (req: Request, res: Response) => {
    const { services, meta } = await ServiceService.getServices(req.query);
    return ApiResponse.success(res, 'Services retrieved successfully', services, meta);
  });

  /**
   * Get featured services
   * GET /api/services/featured
   */
  static getFeatured = asyncHandler(async (req: Request, res: Response) => {
    const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 6;
    const services = await ServiceService.getFeaturedServices(limit);
    return ApiResponse.success(res, 'Featured services retrieved successfully', services);
  });

  /**
   * Get service categories
   * GET /api/services/categories
   */
  static getCategories = asyncHandler(async (req: Request, res: Response) => {
    const categories = await ServiceService.getCategories();
    return ApiResponse.success(res, 'Categories retrieved successfully', categories);
  });

  /**
   * Get service by ID
   * GET /api/services/:id
   */
  static getServiceById = asyncHandler(async (req: Request, res: Response) => {
    const service = await ServiceService.getServiceById(req.params.id);
    return ApiResponse.success(res, 'Service details retrieved successfully', service);
  });

  /**
   * Create new service (Admin)
   * POST /api/services
   */
  static createService = asyncHandler(async (req: Request, res: Response) => {
    const service = await ServiceService.createService(req.body);
    return ApiResponse.created(res, 'Service created successfully', service);
  });

  /**
   * Update service (Admin)
   * PUT /api/services/:id
   */
  static updateService = asyncHandler(async (req: Request, res: Response) => {
    const service = await ServiceService.updateService(req.params.id, req.body);
    return ApiResponse.success(res, 'Service updated successfully', service);
  });

  /**
   * Delete service (Admin)
   * DELETE /api/services/:id
   */
  static deleteService = asyncHandler(async (req: Request, res: Response) => {
    await ServiceService.deleteService(req.params.id);
    return ApiResponse.success(res, 'Service deleted successfully');
  });
}
