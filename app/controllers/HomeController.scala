package controllers

import javax.inject._
import play.api._
import play.api.mvc._
import play.api.libs.json._

/**
 * This controller creates an `Action` to handle HTTP requests to the
 * application's home page.
 */
@Singleton
class HomeController @Inject()(val controllerComponents: ControllerComponents) extends BaseController {

  /**
   * API status endpoint
   */
  def index() = Action { implicit request: Request[AnyContent] =>
    Ok(Json.obj(
      "status" -> "ok",
      "message" -> "Recipe API is running",
      "version" -> "1.0.0"
    ))
  }
}
