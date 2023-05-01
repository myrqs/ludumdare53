import h2d.col.Point;
import Item.Cheese;
import h2d.col.Circle;
import hxd.Res;
import h2d.Anim;
import h2d.Scene;
import h2d.Tile;

class Planet extends Anim{
  var animtiles:Array<Tile> = [];
  var mass:Float = 10.0;
  var field:Int = 500;
  var collisionCircle:Circle = null;
  var rotationSpeed:Float = 0.0001;
  var spawnCountdown:Int = 100;
  var items:Array<Item> = [];
  var planetName:String = "Planet";

  public function new(s2d:Scene){
    super(animtiles, 10, s2d);
  }
  public function getMass():Float{
    return this.mass;
  }
  public function getField():Int{
    return this.field;
  }
  public function getCollisionCircle():Circle{
    return this.collisionCircle;
  }
  public function getItems():Array<Item>{
    return items;
  }
  public function getName():String {
    return planetName;
  }
  private function dropItem(s2d:Scene){
    spawnCountdown = 1000;
  }

  public function update(s2d:Scene){
    this.rotate(this.rotationSpeed);
    if(spawnCountdown <= 0){
      dropItem(s2d);
    }
    spawnCountdown--;
  }
}

class CheesePlanet extends Planet{
  public function new(s2d:Scene, x:Float, y:Float){
    super(s2d);
    this.x = x;
    this.y = y;
    this.field = 1000;
    this.mass = 20.0;
    this.rotationSpeed = 0.01;
    animtiles.push(Res.planets.cheeseplanet.toTile());
    collisionCircle = new Circle(this.x, this.y, animtiles[0].width/2-10);
    for (tile in animtiles){
      tile.dx = -tile.width/2;
      tile.dy = -tile.height/2;
    }
    planetName = "CheesePlanet";
  }
  public override function dropItem(s2d:Scene){
    spawnCountdown = 100;
    var dropx:Float = this.x + Math.random() * (256*2) - 256;
    var dropy:Float = this.y + Math.random() * (256*2) - 256;
    if(!collisionCircle.contains(new Point(dropx, dropy))){
      items.push(new Cheese(s2d, dropx, dropy));
    }
  }
}

class Earth extends Planet{
  public function new(s2d:Scene, x:Float, y:Float){
    super(s2d);
    this.x = x;
    this.y = y;
    this.field = 250;
    this.mass = 10.0;
    this.rotationSpeed = 0.02;
    animtiles.push(Res.planets.earth.toTile());
    collisionCircle = new Circle(this.x, this.y, animtiles[0].width/2-10);
    for (tile in animtiles){
      tile.dx = -tile.width/2;
      tile.dy = -tile.height/2;
    }
    planetName = "Earth";
  }
}
