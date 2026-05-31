const fs = require('fs');
const path = require('path');

const jsDir = path.join(__dirname, 'resources', 'js');

function walkDir(dir) {
    const files = [];
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
        const fullPath = path.join(dir, entry.name);
        if (entry.isDirectory()) {
            files.push(...walkDir(fullPath));
        } else if (entry.name.endsWith('.jsx') && entry.name !== 'app.jsx') {
            files.push(fullPath);
        }
    }
    return files;
}

const files = walkDir(jsDir);
let fixedCount = 0;

for (const file of files) {
    let content = fs.readFileSync(file, 'utf-8');
    
    // Check if file uses route() or route) but doesn't already have route declaration/import
    const usesRoute = /\broute\(/.test(content) || /\broute\)/.test(content);
    const hasRouteDeclared = /const route\b/.test(content) || /import.*\broute\b.*from/.test(content);
    
    if (usesRoute && !hasRouteDeclared) {
        // Find the last import line
        const lines = content.split('\n');
        let lastImportLine = -1;
        for (let i = 0; i < lines.length; i++) {
            if (lines[i].trimStart().startsWith('import ')) {
                lastImportLine = i;
            }
        }
        
        if (lastImportLine >= 0) {
            lines.splice(lastImportLine + 1, 0, '', 'const route = window.route;');
            fs.writeFileSync(file, lines.join('\n'), 'utf-8');
            fixedCount++;
            console.log('Fixed:', path.relative(__dirname, file));
        }
    }
}

console.log(`\nTotal files fixed: ${fixedCount}`);
