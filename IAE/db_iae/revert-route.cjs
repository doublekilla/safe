const fs = require('fs');
const path = require('path');

const jsDir = path.join(__dirname, 'resources', 'js');

function walkDir(dir) {
    const files = [];
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
        const fullPath = path.join(dir, entry.name);
        if (entry.isDirectory()) {
            files.push(...walkDir(fullPath));
        } else if (entry.name.endsWith('.jsx')) {
            files.push(fullPath);
        }
    }
    return files;
}

const files = walkDir(jsDir);
let fixedCount = 0;

for (const file of files) {
    let content = fs.readFileSync(file, 'utf-8');
    
    // Remove the injected line and the blank line after it
    const oldLine = '\nconst route = window.route;\n';
    if (content.includes(oldLine)) {
        content = content.replace(oldLine, '\n');
        fs.writeFileSync(file, content, 'utf-8');
        fixedCount++;
        console.log('Reverted:', path.relative(__dirname, file));
    }
}

console.log(`\nTotal files reverted: ${fixedCount}`);
