import hxd.res.Sound;
import h2d.Scene;
import h2d.Anim;
import h2d.Tile;
import hxd.Res;
import h2d.RenderContext;

class Item extends Anim{
  var animationTiles:Array<Tile> = [];
  var picked:Bool = false;
  var pickupSound:Sound = null;

  public function new(s2d:Scene){
    super(animationTiles, 10, s2d);
  }

  override function sync(ctx:RenderContext) {
    super.sync(ctx);
    if(picked) {
      scaleX -= 0.1;
      scaleY -= 0.1;
      if(scaleX <= 0.1){
        remove();
        pickupSound.play(0.5);
      }
    }
  }
  public function onPickup(){
    picked = true;
  }
}

class Pizza extends Item{
  public function new(s2d:Scene, x:Float, y:Float){
    super(s2d);
    this.x = x;
    this.y = y;
    animationTiles.push(Res.items.pizza1.toTile());
    for (tile in animationTiles){
      tile.dx = -tile.width/2;
      tile.dy = -tile.height/2;
    }
  }
}

class Cheese extends Item{
  public function new(s2d:Scene, x:Float, y:Float){
    super(s2d);
    if(hxd.res.Sound.supportedFormat(Wav)){
      pickupSound = Res.sound.Pickup3;
    }
    this.x = x;
    this.y = y;
    animationTiles.push(Res.items.cheese.toTile());
    for (tile in animationTiles){
      tile.dx = -tile.width/2;
      tile.dy = -tile.height/2;
    }
  }
}

class Sauce extends Item{
  public function new(s2d:Scene, x:Float, y:Float){
    super(s2d);
    if(hxd.res.Sound.supportedFormat(Wav)){
      pickupSound = Res.sound.Pickup4;
    }
    this.x = x;
    this.y = y;
    animationTiles.push(Res.items.sauce.toTile());
    for (tile in animationTiles){
      tile.dx = -tile.width/2;
      tile.dy = -tile.height/2;
    }
  }
}

class Dough extends Item{
  public function new(s2d:Scene, x:Float, y:Float){
    super(s2d);
    if(hxd.res.Sound.supportedFormat(Wav)){
      pickupSound = Res.sound.Pickup5;
    }
    this.x = x;
    this.y = y;
    animationTiles.push(Res.items.dough.toTile());
    for (tile in animationTiles){
      tile.dx = -tile.width/2;
      tile.dy = -tile.height/2;
    }
  }
}
