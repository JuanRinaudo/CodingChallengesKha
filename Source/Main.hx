package;

import kext.Application;
import beesandbombsSineCubes.SineCubesState;

class Main {
	private static var application:Application;
	
	public static function main() {
		beesAndBombsSineCubes();
	}

	private static function beesAndBombsSineCubes() {
		application = new Application(
			{title: SineCubesState.NAME, width: SineCubesState.CANVAS_WIDTH, height: SineCubesState.CANVAS_HEIGHT},
			{initState: SineCubesState}
		);
	}

}