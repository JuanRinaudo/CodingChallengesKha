package;

import kext.Application;
// import beesandbombsSineCubes.SineCubesState;
import simpleChallenges.SimpleLighting;
// import shaderChallenges.TransitionShaders;

class Main {
	private static var application:Application;
	
	public static function main() {
		// application = SineCubesState.initApplication(); //Challenge 001
		application = SimpleLighting.initApplication(); //Challenge 002
		// application = TransitionShaders.initApplication(); //Challenge 003
	}

}