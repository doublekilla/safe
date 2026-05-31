/**
 * Centralized sport type configuration for EithSpace.
 * Use this everywhere instead of hardcoding sport type logic.
 */

export const SPORT_TYPES = {
    badminton:  { label: 'Badminton',  emoji: '🏸', badge: 'badge-info' },
    futsal:     { label: 'Futsal',     emoji: '⚽', badge: 'badge-success' },
    basketball: { label: 'Basket',     emoji: '🏀', badge: 'badge-warning' },
    padel:      { label: 'Padel',      emoji: '🎾', badge: 'badge-accent' },
    volleyball: { label: 'Voli',       emoji: '🏐', badge: 'badge-info' },
};

export const getSportEmoji = (type) => SPORT_TYPES[type]?.emoji || '🏟️';
export const getSportLabel = (type) => SPORT_TYPES[type]?.label || type;
export const getSportBadge = (type) => SPORT_TYPES[type]?.badge || 'badge-info';
export const getSportDisplay = (type) => `${getSportEmoji(type)} ${getSportLabel(type)}`;

/**
 * Returns all sport types as an array of { value, label, emoji } for use in select dropdowns.
 */
export const sportTypeOptions = Object.entries(SPORT_TYPES).map(([value, config]) => ({
    value,
    label: config.label,
    emoji: config.emoji,
}));
