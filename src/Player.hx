import h2d.Anim;
import h2d.Scene;
import h2d.Tile;
import hxd.Res;
import hxd.res.Sound;

class Player extends Anim{
  var animationTiles:Array<Tile> = [];
  var accelerationAnimationTiles:Array<Tile> = [];
  var turboAnimationTiles:Array<Tile> = [];
  var deathAnimationTiles:Array<Tile> = [];
  public var accelerationX:Float = 0.0;
  public var speedX:Float = 0.0;
  public var accelerationY:Float = 0.0;
  public var speedY:Float = 0.0;
  public var isDead:Bool = false;
  var turbo:Int = 100;
  var turboOn:Bool = false;
  var weight:Float = 100.0;
  var thrustsound:Sound = null;
  var turbosound:Sound = null;
  var currentThrustSound:Sound = null;
  var deathSound:Sound = null;
  var soundIsPlaying:Bool = false;

  public function new(s2d:Scene, x:Float, y:Float){
    super(animationTiles, 10, s2d);
		if (hxd.res.Sound.supportedFormat(Wav)) {
      thrustsound = hxd.Res.sound.thrust11;
      turbosound = hxd.Res.sound.turbo10;
      deathSound = hxd.Res.sound.explosion;
    }
    this.x = x;
    this.y = y;
    animationTiles.push(Res.player.player.toTile());
    for (i in 0...animationTiles.length) {
      animationTiles[i].dy = -animationTiles[i].height/2;
      animationTiles[i].dx = -animationTiles[i].width/2;
    }
    accelerationAnimationTiles.push(Res.player.player2.toTile());
    accelerationAnimationTiles.push(Res.player.player3.toTile());
    accelerationAnimationTiles.push(Res.player.player4.toTile());
    accelerationAnimationTiles.push(Res.player.player5.toTile());
    accelerationAnimationTiles.push(Res.player.player6.toTile());
    accelerationAnimationTiles.push(Res.player.player7.toTile());
    accelerationAnimationTiles.push(Res.player.player8.toTile());
    for (i in 0...accelerationAnimationTiles.length) {
      accelerationAnimationTiles[i].dy = -accelerationAnimationTiles[i].height/2;
      accelerationAnimationTiles[i].dx = -accelerationAnimationTiles[i].width/2;
    }
    turboAnimationTiles.push(Res.player.player_turbo1.toTile());
    turboAnimationTiles.push(Res.player.player_turbo2.toTile());
    turboAnimationTiles.push(Res.player.player_turbo3.toTile());
    turboAnimationTiles.push(Res.player.player_turbo4.toTile());
    turboAnimationTiles.push(Res.player.player_turbo5.toTile());
    turboAnimationTiles.push(Res.player.player_turbo6.toTile());
    turboAnimationTiles.push(Res.player.player_turbo7.toTile());
    for (i in 0...turboAnimationTiles.length) {
      turboAnimationTiles[i].dy = -turboAnimationTiles[i].height/2;
      turboAnimationTiles[i].dx = -turboAnimationTiles[i].width/2;
    }
    deathAnimationTiles.push(Res.player.death1.toTile());
    deathAnimationTiles.push(Res.player.death2.toTile());
    deathAnimationTiles.push(Res.player.death3.toTile());
    deathAnimationTiles.push(Res.player.death4.toTile());
    deathAnimationTiles.push(Res.player.death5.toTile());
    deathAnimationTiles.push(Res.player.death6.toTile());
    for (i in 0...deathAnimationTiles.length) {
      deathAnimationTiles[i].dy = -deathAnimationTiles[i].height/2;
      deathAnimationTiles[i].dx = -deathAnimationTiles[i].width/2;
    }
  }

  private function mine(){
  }

  public function update(){
    if(hxd.Key.isDown(hxd.Key.W)) {
      if(turbo >= 0 && turboOn){
        this.frames = turboAnimationTiles;
        this.accelerationY = -0.05 * Math.cos(this.rotation);
        this.accelerationX = 0.05 * Math.sin(this.rotation);
        turbo--;
        if(!soundIsPlaying){
          soundIsPlaying = true;
          turbosound.play(true, 0.05);
        }
      }else{
        this.frames = accelerationAnimationTiles;
        this.accelerationY = -0.02 * Math.cos(this.rotation);
        this.accelerationX = 0.02 * Math.sin(this.rotation);
        if(!soundIsPlaying){
          soundIsPlaying = true;
          thrustsound.play(true, 0.05);
        }
      }
    }
    if(hxd.Key.isReleased(hxd.Key.W)) {
      this.accelerationY = 0.0;
      this.accelerationX = 0.0;
      this.frames = animationTiles;
      thrustsound.stop();
      turbosound.stop();
      this.soundIsPlaying = false;
    }
    if(hxd.Key.isDown(hxd.Key.D)){
      this.rotate(0.1);
    }
    if(hxd.Key.isDown(hxd.Key.A)){
      this.rotate(-0.1);
    }
    if(hxd.Key.isDown(hxd.Key.SPACE)){
      mine();
    }
  /*
   if(hxd.Key.isDown(hxd.Key.SHIFT)){
      turboOn = true;
      soundIsPlaying = false;
    }
*/
    this.speedY += this.accelerationY;
    this.speedX += this.accelerationX;
    this.y += this.speedY;
    this.x += this.speedX;
    if(turbo <= 0){
      turbosound.stop();
      soundIsPlaying = false;
      turboOn = false;
    }
    if(turbo <= 100 && !turboOn) turbo++;
  }
  public function applyForce(forceX:Float, forceY:Float){
    if(forceX == 0) accelerationX = 0.0;
    if(forceY == 0) accelerationY = 0.0;
    accelerationX += forceX/1000;
    accelerationY += forceY/1000;
  }
  public function die(){
    this.frames = deathAnimationTiles;
    this.onAnimEnd = function() {
      deathSound.play(0.25);
      thrustsound.stop();
      isDead = true;
      remove();
    }
  }
}
