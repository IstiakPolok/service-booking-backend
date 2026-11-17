import jwt from 'jsonwebtoken';
import { User, IUser } from '../models/user.model.js';
import { ENV } from '../config/env.js';
import { ApiError } from '../utils/apiError.js';
import { JwtPayload } from '../middlewares/auth.middleware.js';

export class AuthService {
  /**
   * Generate JWT Token
   */
  static generateToken(user: IUser): string {
    const payload: JwtPayload = {
      id: user.id || (user._id as any).toString(),
      email: user.email,
      role: user.role,
    };

    return jwt.sign(payload, ENV.JWT_SECRET, {
      expiresIn: ENV.JWT_EXPIRES_IN as any,
    });
  }

  /**
   * Register a new user
   */
  static async register(data: {
    name: string;
    email: string;
    password: string;
    phone?: string;
    avatar?: string;
  }): Promise<{ user: IUser; token: string }> {
    const existing = await User.findOne({ email: data.email.toLowerCase() });
    if (existing) {
      throw ApiError.conflict('An account with this email address already exists');
    }

    const user = await User.create({
      name: data.name,
      email: data.email.toLowerCase(),
      password: data.password,
      phone: data.phone || '',
      avatar: data.avatar || undefined,
    });

    const token = this.generateToken(user);
    return { user, token };
  }

  /**
   * Log in user with email and password
   */
  static async login(data: {
    email: string;
    password: string;
  }): Promise<{ user: IUser; token: string }> {
    // Need password explicitly because select: false in schema
    const user = await User.findOne({ email: data.email.toLowerCase() }).select('+password');
    if (!user) {
      throw ApiError.unauthorized('Invalid email or password');
    }

    const isMatch = await user.comparePassword(data.password);
    if (!isMatch) {
      throw ApiError.unauthorized('Invalid email or password');
    }

    const token = this.generateToken(user);
    // Remove password before returning
    const userJson = user.toJSON();
    return { user: userJson as any, token };
  }

  /**
   * Change user password
   */
  static async changePassword(
    userId: string,
    currentPass: string,
    newPass: string
  ): Promise<void> {
    const user = await User.findById(userId).select('+password');
    if (!user) {
      throw ApiError.notFound('User not found');
    }

    const isMatch = await user.comparePassword(currentPass);
    if (!isMatch) {
      throw ApiError.badRequest('Current password is incorrect');
    }

    user.password = newPass;
    await user.save();
  }

  /**
   * Update user profile
   */
  static async updateProfile(
    userId: string,
    updateData: { name?: string; phone?: string; avatar?: string }
  ): Promise<IUser> {
    const user = await User.findByIdAndUpdate(
      userId,
      { $set: updateData },
      { new: true, runValidators: true }
    );

    if (!user) {
      throw ApiError.notFound('User not found');
    }

    return user;
  }
}

