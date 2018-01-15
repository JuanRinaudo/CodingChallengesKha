let project = new Project('Coding Challenges Kha');

project.addLibrary('zui');
project.addLibrary('kext');
project.addLibrary('tweenxcore');

project.addShaders('Assets/Shaders/**');

project.addAssets('Assets/Common/**');
project.addAssets('Assets/BasicGeometry/**');

project.addSources('Source');

resolve(project);