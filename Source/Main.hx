package;

import kext.g4basics.G4Constants;
import kha.graphics4.ConstantLocation;
import kext.Application;
// import replicationChallenges.SineCubesState;
// import simpleChallenges.SimpleLighting;
// import shaderChallenges.TransitionShaders;
// import shaderChallenges.TextureCutoffMeshShader;
// import shaderChallenges.PostProcessingShader;
// import gameChallenges.SimpleCarGame;
// import simpleChallenges.SimpleBones;
// import shaderChallenges.GameOfLifeShader;
import shaderChallenges.FlowFieldShader;

class Main {
	private static var application:Application;
	
	public static function main() {
		// application = SineCubesState.initApplication(); //Challenge 001
		// application = SimpleLighting.initApplication(); //Challenge 002
		// application = TransitionShaders.initApplication(); //Challenge 003
		// application = TextureCutoffMeshShader.initApplication(); //Challenge 004
		// application = PostProcessingShader.initApplication(); //Challenge 005
		// application = SimpleCarGame.initApplication(); //Challenge 006
		// application = SimpleBones.initApplication(); //Challenge 007
		// application = GameOfLifeShader.initApplication(); //Challenge 008
		application = FlowFieldShader.initApplication(); //Challenge 009
	}

}