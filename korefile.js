let fs = require('fs');
let path = require('path');
let project = new Project('Coding Challenges Kha', __dirname);
project.targetOptions = {"html5":{},"flash":{},"android":{},"ios":{}};
project.setDebugDir('build/windows');
Promise.all([Project.createProject('build/windows-build', __dirname), Project.createProject('C:/Users/JuanRinaudo/Desktop/Development/CodingChallengesKha/Kha', __dirname), Project.createProject('C:/Users/JuanRinaudo/Desktop/Development/CodingChallengesKha/Kha/Kore', __dirname)]).then((projects) => {
	for (let p of projects) project.addSubProject(p);
	let libs = [];
	if (fs.existsSync(path.join('Libraries/zui', 'korefile.js'))) {
		libs.push(Project.createProject('Libraries/zui', __dirname));
	}
	if (fs.existsSync(path.join('Libraries/kext', 'korefile.js'))) {
		libs.push(Project.createProject('Libraries/kext', __dirname));
	}
	if (fs.existsSync(path.join('C:/HaxeToolkit/haxe/lib/tweenxcore', 'korefile.js'))) {
		libs.push(Project.createProject('C:/HaxeToolkit/haxe/lib/tweenxcore', __dirname));
	}
	Promise.all(libs).then((libprojects) => {
		for (let p of libprojects) project.addSubProject(p);
		resolve(project);
	});
});
