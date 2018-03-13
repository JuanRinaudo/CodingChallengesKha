let project = new Project('Coding Challenges Kha');

project.addLibrary('zui');
project.addLibrary('kext');
project.addLibrary('tweenxcore');

project.addShaders('Assets/Shaders/**');
project.addShaders('Assets/PostProcessingShaders/**');

// project.addAssets('Assets/Images/**');
project.addAssets('Assets/Common/**');
project.addAssets('Assets/BasicGeometry/**');
project.addAssets('Assets/Models/**');

// project.addAssets('Assets/Transitions/**');
project.addAssets('Assets/GameAssets/SimpleCarGame');

project.addSources('Source');

project.addParameter('-dce std');

resolve(project);