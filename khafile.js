let project = new Project('Coding Challenges Kha');

project.addLibrary('zui');
project.addLibrary('kext');
project.addLibrary('tweenxcore');

project.addShaders('Assets/Shaders/**');

project.addAssets('Assets/Common/**');

// project.addAssets('Assets/Models/**');
// project.addAssets('Assets/Bones/**');

// project.addAssets('Assets/Transitions/**');
// project.addAssets('Assets/GameAssets/SimpleCarGame');

//005 - Post Processing
project.addAssets('Assets/BasicGeometry/**');
project.addAssets('Assets/Images/**');
project.addShaders('Assets/PostProcessingShaders/**');

project.addSources('Source');

project.addParameter('-dce std');

resolve(project);