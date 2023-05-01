import Item.Cheese;
import Item.Sauce;
import Item.Dough;
import Planet.Sun;
import h2d.Console;
import hxd.Res;
import h2d.SpriteBatch;
import Item.Pizza;
import Planet;
import Player;
import h2d.Font;
import h2d.Text;
import h2d.Bitmap;
import hxd.res.Sound;

class Main extends hxd.App {
  var player:Player;
  var planets:Array<Planet> = [];
  var font:Font = null;
  var tf:Text = null;
  var distanceText:Text = null;
  var nextDelivery:String = "home";
  var deliveryTarget:Planet = null;
  var cheeseCount:Int = 0;
  var sauceCount:Int = 0;
  var doughCount:Int = 0;
  var pizzaCount:Int = 0;
  var coinsCount:Int = 0;
  var arrow:Bitmap;
  var console:Console;
  var bakingCounter:Int = 250;
  var deliveryCounter:Int = 50;
  var coinSound:Sound = null;

  override function init(){
    super.init();

		if (hxd.res.Sound.supportedFormat(Wav)) {
      coinSound = hxd.Res.sound.coin;
    }
    font = hxd.res.DefaultFont.get();

		s2d.scaleMode = Zoom(2.0);
    player = new Player(s2d, -512, -512);
    tf = new h2d.Text(font, s2d);
    tf.textAlign = Center;

    planets.push(new CheesePlanet(s2d, 512, 512));
    planets.push(new Earth(s2d, -1024, 1024));
    planets.push(new SaucePlanet(s2d,-1024, -2048));
    planets.push(new DoughPlanet(s2d,-2048, -1024));
    planets.push(new Sun(s2d, 2048, 0));
    deliveryTarget = planets[0];
    s2d.camera.follow = player;
		s2d.camera.anchorY = 0.5;
		s2d.camera.anchorX = 0.5;
    var stars = new SpriteBatch(Res.star1.toTile(), s2d);
    for(x in 0...2000){
          var star = new BatchElement(Res.star1.toTile());
          star.x = Math.random() * (4096*2) - 4096;
          star.y = Math.random() * (4096*2) - 4096;
          stars.add(star);
    }

    arrow = new Bitmap(hxd.Res.arrow.toTile(), s2d);

    distanceText = new h2d.Text(font, arrow);
    distanceText.textAlign = Center;
    distanceText.scale(0.75);
    distanceText.x = -32;
    distanceText.textColor = 0x6ABE30;
    arrow.tile.dx = -arrow.tile.width;
    arrow.tile.dy = -arrow.tile.height/2;
  }

  override function update(dt:Float){
    super.update(dt);
    player.update();
    tf.x = player.x;
    tf.y = player.y + 64;

    var dx = arrow.getBounds().getCenter().x - deliveryTarget.getBounds().getCenter().x;
    var dy = arrow.getBounds().getCenter().y - deliveryTarget.getBounds().getCenter().y;
    arrow.rotation = Math.atan2(dy, dx);
    distanceText.text = "" + Math.round(Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2)));
    distanceText.rotation = 1.5;
    arrow.x = player.x;
    arrow.y = player.y;

    var forceX = 0.0;
    var forceY = 0.0;
    for(planet in planets){
      var distanceX = planet.getBounds().getCenter().x - player.getBounds().getCenter().x;
      var distanceY = planet.getBounds().getCenter().y - player.getBounds().getCenter().y;
      var distance = Math.sqrt(Math.pow(distanceX, 2) + Math.pow(distanceY, 2));
      if(planet.getCollisionCircle().collideBounds(player.getBounds())){
        player.die();
      }
      if(planet is Sun){
        if(distance <= 512){
          if(cheeseCount >= 1 && sauceCount >= 1 && doughCount >= 1){
            bake();
          }
        }
      }
      if(planet is Earth){
        if(distance <= 256){
          if(pizzaCount >= 1){
            deliver();
          }
        }
      }

      if(distance < planet.getField()){
        forceX += planet.getMass() * distanceX /  Math.pow(distance, 2);
        forceY += planet.getMass() * distanceY /  Math.pow(distance, 2);
      }
      planet.update(s2d);

      for(item in planet.getItems()){
        if(item.getBounds().intersects(player.getBounds())){
          item.onPickup();
          if(item is Cheese) cheeseCount++;
          if(item is Sauce) sauceCount++;
          if(item is Dough) doughCount++;
          planet.getItems().remove(item);
        }
      }
    }
    player.applyForce(forceX, forceY);
    tf.text = "target: " + deliveryTarget.getName() + "\ncheese: " + cheeseCount + "\nsauce: " + sauceCount + "\ndough: " + doughCount + "\npizzas: " + pizzaCount + "\ncoins: " + coinsCount;
    if(hxd.Key.isPressed(hxd.Key.TAB)){
      var nextPlanetIndex = planets.indexOf(deliveryTarget) + 1;
      if(nextPlanetIndex >= planets.length) nextPlanetIndex = 0;
      deliveryTarget = planets[nextPlanetIndex];
    }
    //tf.text += "\nforceX: " + forceX + " forceY: " + forceY + "\naccelerationX: " + player.accelerationX + " accelerationY: " + player.accelerationY + "\nspeedX: " + player.speedX + " speedY: " + player.speedY;
  }

  private function bake(){
    if(bakingCounter-- <= 0){
      bakingCounter = 250;
      doughCount--;
      sauceCount--;
      cheeseCount--;
      pizzaCount++;
    }
  }
  private function deliver(){
    if(deliveryCounter-- <= 0){
      deliveryCounter = 50;
      pizzaCount--;
      coinsCount++;
      coinSound.play();
    }
  }
  static function main(){
    hxd.Res.initEmbed();
    new Main();
  }
}
