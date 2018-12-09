let project = new Project('Coding Challenges Kha');

project.addLibrary('zui');
project.addLibrary('kext');
project.addLibrary('tweenxcore');

project.addShaders('Assets/Shaders/**');
// project.addShaders('Assets/GameOfLife/**');
// project.addShaders('Assets/PostProcessingShaders/**');

project.addAssets('Assets/Common/**');

// project.addAssets('Assets/Images/**');
// project.addAssets('Assets/BasicGeometry/**');
// project.addAssets('Assets/Models/**');
// project.addAssets('Assets/Bones/**');

// project.addAssets('Assets/Transitions/**');
// project.addAssets('Assets/GameAssets/SimpleCarGame');

project.addShaders('Assets/ImageSlideshow/Shaders/**');
project.addAssets('Assets/ImageSlideshow/Images/**');

project.addSources('Source');

project.addParameter('-dce std');

resolve(project);