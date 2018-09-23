let fs = require('fs');
let path = require('path');
let project = new Project('Coding Challenges Kha');
project.addDefine('HXCPP_API_LEVEL=332');
project.targetOptions = {"html5":{},"flash":{},"android":{},"ios":{}};
project.setDebugDir('build/windows');
await project.addProject('build/windows-build');
await project.addProject('C:/Users/Us/Desktop/Development/CodingChallengesKha/Kha');
if (fs.existsSync(path.join('Libraries/zui', 'korefile.js'))) {
	await project.addProject('Libraries/zui');
}
if (fs.existsSync(path.join('Libraries/kext', 'korefile.js'))) {
	await project.addProject('Libraries/kext');
}
if (fs.existsSync(path.join('C:/HaxeToolkit/haxe/lib/tweenxcore', 'korefile.js'))) {
	await project.addProject('C:/HaxeToolkit/haxe/lib/tweenxcore');
}
resolve(project);
