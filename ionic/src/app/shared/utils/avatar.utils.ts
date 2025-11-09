/**
 * Avatar utility service for generating patient avatars
 * Provides consistent avatar generation across the app
 */
export class AvatarUtils {
  
  /**
   * Generate initials from full name
   */
  static getInitials(firstName: string, lastName?: string): string {
    if (!firstName) return '?';
    
    const first = firstName.trim()[0]?.toUpperCase() || '';
    const last = lastName?.trim()[0]?.toUpperCase() || '';
    
    return last ? `${first}${last}` : first;
  }
  
  /**
   * Get avatar color based on name hash (consistent per name)
   */
  static getAvatarColor(name: string): string {
    if (!name) return '#cccccc';
    
    // Hash name to number
    let hash = 0;
    for (let i = 0; i < name.length; i++) {
      hash = name.charCodeAt(i) + ((hash << 5) - hash);
    }
    
    // Convert to color index (8 distinct colors)
    const colors = [
      '#FF6B6B', // Red
      '#4ECDC4', // Teal
      '#45B7D1', // Blue
      '#FFA07A', // Orange
      '#98D8C8', // Green
      '#A8A8FF', // Purple
      '#FFB6C1', // Pink
      '#FFD93D'  // Yellow
    ];
    
    const index = Math.abs(hash) % colors.length;
    return colors[index];
  }
  
  /**
   * Get avatar style object for inline styling
   */
  static getAvatarStyle(firstName: string, lastName?: string): { backgroundColor: string; color: string } {
    const fullName = `${firstName} ${lastName || ''}`.trim();
    return {
      backgroundColor: this.getAvatarColor(fullName),
      color: '#ffffff'
    };
  }
  
  /**
   * Generate placeholder image URL (for future photo support)
   */
  static getPlaceholderUrl(firstName: string, lastName?: string): string {
    const initials = this.getInitials(firstName, lastName);
    const color = this.getAvatarColor(`${firstName} ${lastName || ''}`).replace('#', '');
    
    // Using UI Avatars API for placeholder generation
    return `https://ui-avatars.com/api/?name=${encodeURIComponent(initials)}&background=${color}&color=fff&size=128&bold=true`;
  }
  
  /**
   * Get gender-based avatar icon (fallback for no name)
   */
  static getGenderIcon(gender: 'M' | 'F' | 'Otro' | string): string {
    switch (gender) {
      case 'M': return 'man-outline';
      case 'F': return 'woman-outline';
      default: return 'person-outline';
    }
  }
}
