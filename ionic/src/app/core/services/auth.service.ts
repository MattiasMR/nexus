import { Injectable, inject } from '@angular/core';
import { Router } from '@angular/router';
import { Auth, user, signInWithEmailAndPassword, signOut } from '@angular/fire/auth';
import { Observable } from 'rxjs';

/**
 * Authentication Service - Placeholder for Phase 3
 * 
 * TODO (Phase 3 - Authentication):
 * - Implement login with Firebase Auth
 * - Implement logout
 * - Add user roles (médico, enfermería, admin)
 * - Add permission system
 * - Create auth guard for protected routes
 * - Add currentUser$ observable
 * - Add getProfesionalData() to fetch from profesionales/ collection
 * 
 * DEFERRED: This service is intentionally empty. Authentication will be
 * implemented last after all core medical workflows are complete and tested.
 */
@Injectable({ providedIn: 'root' })
export class AuthService {
  // TODO: Uncomment when implementing Phase 3
  // private auth = inject(Auth);
  // private router = inject(Router);
  
  // TODO: Observable for current user
  // user$ = user(this.auth);
  
  /**
   * TODO Phase 3: Login with email/password
   * 
   * Example implementation:
   * ```typescript
   * async login(email: string, password: string): Promise<void> {
   *   try {
   *     const credential = await signInWithEmailAndPassword(this.auth, email, password);
   *     // Fetch profesional data from Firestore
   *     const profesional = await this.getProfesionalData(credential.user.uid);
   *     // Store role, navigate to dashboard
   *     this.router.navigateByUrl('/tabs/tab1');
   *   } catch (error) {
   *     throw new Error('Login failed: ' + error.message);
   *   }
   * }
   * ```
   */
  async login(email: string, password: string): Promise<void> {
    // TODO Phase 3: Implement
    console.warn('AuthService.login() - Not implemented yet (Phase 3)');
    throw new Error('Authentication not implemented');
  }
  
  /**
   * TODO Phase 3: Logout
   * 
   * Example implementation:
   * ```typescript
   * async logout(): Promise<void> {
   *   await signOut(this.auth);
   *   this.router.navigateByUrl('/login');
   * }
   * ```
   */
  async logout(): Promise<void> {
    // TODO Phase 3: Implement
    console.warn('AuthService.logout() - Not implemented yet (Phase 3)');
  }
  
  /**
   * TODO Phase 3: Check if user is authenticated
   * 
   * Example implementation:
   * ```typescript
   * isAuthenticated(): Observable<boolean> {
   *   return this.user$.pipe(map(user => !!user));
   * }
   * ```
   */
  isAuthenticated(): boolean {
    // TODO Phase 3: Implement
    // For now, return true to bypass auth during development
    return true;
  }
  
  /**
   * TODO Phase 3: Get current user role
   * 
   * Example implementation:
   * ```typescript
   * async getCurrentUserRole(): Promise<'medico' | 'enfermeria' | 'admin'> {
   *   const user = await firstValueFrom(this.user$);
   *   const profesional = await this.getProfesionalData(user.uid);
   *   return profesional.rol;
   * }
   * ```
   */
  getCurrentUserRole(): string {
    // TODO Phase 3: Implement
    // For now, return 'medico' as default
    return 'medico';
  }
  
  /**
   * TODO Phase 3: Check if user has specific permission
   * 
   * Example implementation:
   * ```typescript
   * async hasPermission(permission: string): Promise<boolean> {
   *   const role = await this.getCurrentUserRole();
   *   const permissions = ROLE_PERMISSIONS[role];
   *   return permissions.includes(permission);
   * }
   * ```
   */
  hasPermission(permission: string): boolean {
    // TODO Phase 3: Implement
    // For now, return true (all permissions during development)
    return true;
  }
}

/**
 * TODO Phase 3: Define role permissions
 * 
 * Example:
 * ```typescript
 * const ROLE_PERMISSIONS = {
 *   medico: ['view_patients', 'create_consultation', 'prescribe_medication', 'order_exams'],
 *   enfermeria: ['view_patients', 'create_consultation', 'record_vitals'],
 *   admin: ['all_permissions', 'manage_users', 'view_reports']
 * };
 * ```
 */
