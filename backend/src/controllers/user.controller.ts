import { Request, Response } from 'express';
import { AuthService } from '../services/auth.service.js';
import { ApiResponse } from '../utils/apiResponse.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { ApiError } from '../utils/apiError.js';

export class UserController {
  /**
   * Get user profile
   * GET /api/users/profile
   */
  static getProfile = asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) {
      throw ApiError.unauthorized();
    }
    return ApiResponse.success(res, 'User profile retrieved successfully', req.user);
  });

  /**
   * Update user profile
   * PUT /api/users/profile
   */
  static updateProfile = asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) {
      throw ApiError.unauthorized();
    }
    const { name, phone, avatar } = req.body;
    const updatedUser = await AuthService.updateProfile(req.user.id, {
      name,
      phone,
      avatar,
    });

    return ApiResponse.success(res, 'User profile updated successfully', updatedUser);
  });
}

