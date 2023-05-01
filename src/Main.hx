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
import hxd.snd.Manager;

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
  var started:Bool = false;
  var playerText:Text = null;
  var bakeSound:Sound = null;
  var musicResource:Sound = null;

  function start() {

		s2d.scaleMode = Zoom(2.0);
    player = new Player(s2d, -512, -512);
    s2d.camera.follow = player;
		s2d.camera.anchorY = 0.5;
		s2d.camera.anchorX = 0.5;
    playerText = new h2d.Text(font, s2d);
    playerText.textAlign = Center;

    arrow = new Bitmap(hxd.Res.arrow.toTile(), s2d);
    distanceText = new h2d.Text(font, arrow);
    distanceText.textAlign = Center;
    distanceText.scale(0.75);
    distanceText.x = -32;
    distanceText.textColor = 0x6ABE30;
    arrow.tile.dx = -arrow.tile.width;
    arrow.tile.dy = -arrow.tile.height/2;

    planets.push(new CheesePlanet(s2d, 512, 512));
    planets.push(new Earth(s2d, -1024, 1024));
    planets.push(new SaucePlanet(s2d,-1024, -2048));
    planets.push(new DoughPlanet(s2d,-2048, -1024));
    planets.push(new Sun(s2d, 2048, 0));
    deliveryTarget = planets[0];

    var stars = new SpriteBatch(Res.star1.toTile(), s2d);
    for(i in 0...2000){
          var star = new BatchElement(Res.star1.toTile());
          star.x = Math.random() * (4096*2) - 4096;
          star.y = Math.random() * (4096*2) - 4096;
          stars.add(star);
    }
  }

  override function init(){
    super.init();

		if (hxd.res.Sound.supportedFormat(Wav)) {
      coinSound = hxd.Res.sound.coin;
      bakeSound = hxd.Res.sound.powerup1;
      musicResource = hxd.Res.sound.track1;
    }
		if (musicResource != null) {
			musicResource.play(true, 0.25);
		}
    font = hxd.res.DefaultFont.get();
  }

  override function update(dt:Float){
    if(started) {
			if (tf == null) {
				tf = new Text(font);
				s2d.addChild(tf);
			}
      if(player.isDead){
		    tf.setPosition(-10000.0, -10000.0);
			  s2d.camera.anchorX = 0.5;
			  s2d.camera.anchorY = 0.25;
		    s2d.camera.follow = tf;
        s2d.scaleMode = Zoom(3.5);
        tf.text = "~GAME OVER~\nyou lost!\n\nyou got: " + coinsCount + " coins by delivering pizza\n\n SPACE - to try again";
        tf.textAlign = Center;
        tf.textColor = 0xAC3232;
        if(hxd.Key.isPressed(hxd.Key.SPACE)) {
          s2d.removeChildren();
          tf = null;
          cheeseCount = 0;
          sauceCount = 0;
          doughCount = 0;
          pizzaCount = 0;
          coinsCount = 0;
          started = false;
        }
        super.update(dt);
        return;
      }
      super.update(dt);
      player.update();
      playerText.x = player.x;
      playerText.y = player.y + 64;

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
      playerText.text = "target: " + deliveryTarget.getName() + "\ncheese: " + cheeseCount + "\nsauce: " + sauceCount + "\ndough: " + doughCount + "\npizzas: " + pizzaCount + "\ncoins: " + coinsCount;
      if(hxd.Key.isPressed(hxd.Key.TAB)){
        var nextPlanetIndex = planets.indexOf(deliveryTarget) + 1;
        if(nextPlanetIndex >= planets.length) nextPlanetIndex = 0;
        deliveryTarget = planets[nextPlanetIndex];
      }
			if (hxd.Key.isPressed(hxd.Key.M)) {
				if (Manager.get().masterVolume >= 1.0)
					Manager.get().masterVolume = 0.0;
				else
					Manager.get().masterVolume = 1.0;
			}
    }else{
      if(tf == null) {
        tf = new Text(font);
        s2d.addChild(tf);
      }
      tf.setPosition(-10000.0,-10000.0);
      s2d.scaleMode = Zoom(2.5);
      s2d.camera.anchorX = 0.5;
      s2d.camera.anchorY = 0.25;
      tf.text = "SPACE - to start delivering\nM - to mute";
      tf.textAlign = Center;
      tf.textColor = 0xAC3232;
      s2d.camera.follow = tf;
      if(hxd.Key.isPressed(hxd.Key.SPACE)) {
        start();
        started = true;
        s2d.removeChild(tf);
        tf = null;
      }
			if (hxd.Key.isPressed(hxd.Key.M)) {
				if (Manager.get().masterVolume >= 1.0)
					Manager.get().masterVolume = 0.0;
				else
					Manager.get().masterVolume = 1.0;
			}
      super.update(dt);
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
      bakeSound.play();
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
