let project = new Project('Coding Challenges Kha');

project.addLibrary('zui');
project.addLibrary('kext');
project.addLibrary('tweenxcore');

project.addShaders('Assets/Shaders/**');

project.addAssets('Assets/Common/**');
project.addAssets('Assets/BasicGeometry/**');
project.addAssets('Assets/Models/**');
// project.addAssets('Assets/Transitions/**');

project.addSources('Source');

resolve(project);