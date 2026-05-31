import { route as ziggyRoute } from '../../vendor/tightenco/ziggy/dist/index.esm.js';

// Make route available globally for all components
// This is needed because ESM modules can't access implicit globals
window.route = ziggyRoute;

export { ziggyRoute as route };
