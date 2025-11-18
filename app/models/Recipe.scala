package models

import play.api.libs.json._
import java.time.LocalDateTime

case class Recipe(
                   id: Option[Long] = None,
                   title: String,
                   making_time: String,
                   serves: String,
                   ingredients: String,
                   cost: Int,
                   created_at: Option[LocalDateTime] = None,
                   updated_at: Option[LocalDateTime] = None
                 )

object Recipe {
  implicit val dateFormat: Format[LocalDateTime] = new Format[LocalDateTime] {
    def writes(dt: LocalDateTime): JsValue = JsString(dt.toString)
    def reads(json: JsValue): JsResult[LocalDateTime] = json match {
      case JsString(s) => JsSuccess(LocalDateTime.parse(s))
      case _ => JsError("Expected date string")
    }
  }

  implicit val recipeFormat: Format[Recipe] = Json.format[Recipe]
}