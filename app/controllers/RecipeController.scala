package controllers

import javax.inject._
import play.api.mvc._
import play.api.libs.json._
import play.api.db.Database
import models.Recipe

@Singleton
class RecipeController @Inject()(
                                  cc: ControllerComponents,
                                  db: Database
                                ) extends AbstractController(cc) {

  // POST /recipes - 创建食谱
  def create = Action(parse.json) { request =>
    request.body.validate[Recipe].fold(
      errors => {
        Ok(Json.obj(
          "message" -> "Recipe creation failed!",
          "required" -> "title, making_time, serves, ingredients, cost"
        ))
      },
      recipe => {
        db.withConnection { conn =>
          val sql = """
            INSERT INTO recipes (title, making_time, serves, ingredients, cost, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
          """
          val stmt = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)
          stmt.setString(1, recipe.title)
          stmt.setString(2, recipe.making_time)
          stmt.setString(3, recipe.serves)
          stmt.setString(4, recipe.ingredients)
          stmt.setInt(5, recipe.cost)
          stmt.executeUpdate()

          val rs = stmt.getGeneratedKeys
          if (rs.next()) {
            val id = rs.getLong(1)
            val createdRecipe = getRecipeById(id)
            Ok(Json.obj(
              "message" -> "Recipe successfully created!",
              "recipe" -> Json.arr(createdRecipe)
            ))
          } else {
            InternalServerError(Json.obj("message" -> "Failed to create recipe"))
          }
        }
      }
    )
  }

  // GET /recipes - 获取所有食谱
  def list = Action {
    db.withConnection { conn =>
      val sql = "SELECT * FROM recipes"
      val stmt = conn.createStatement()
      val rs = stmt.executeQuery(sql)

      var recipes = List[JsValue]()
      while (rs.next()) {
        recipes = recipes :+ Json.obj(
          "id" -> rs.getLong("id"),
          "title" -> rs.getString("title"),
          "making_time" -> rs.getString("making_time"),
          "serves" -> rs.getString("serves"),
          "ingredients" -> rs.getString("ingredients"),
          "cost" -> rs.getString("cost")
        )
      }

      Ok(Json.obj("recipes" -> recipes))
    }
  }

  // GET /recipes/:id - 获取单个食谱
  def show(id: Long) = Action {
    val recipe = getRecipeById(id)
    if (recipe != JsNull) {
      Ok(Json.obj("message" -> "Recipe details by id", "recipe" -> Json.arr(recipe)))
    } else {
      NotFound(Json.obj("message" -> "No Recipe found"))
    }
  }

  // PATCH /recipes/:id - 更新食谱
  def update(id: Long) = Action(parse.json) { request =>
    request.body.validate[Recipe].fold(
      errors => {
        Ok(Json.obj("message" -> "Recipe update failed!"))
      },
      recipe => {
        db.withConnection { conn =>
          val sql = """
            UPDATE recipes
            SET title = ?, making_time = ?, serves = ?, ingredients = ?, cost = ?, updated_at = CURRENT_TIMESTAMP
            WHERE id = ?
          """
          val stmt = conn.prepareStatement(sql)
          stmt.setString(1, recipe.title)
          stmt.setString(2, recipe.making_time)
          stmt.setString(3, recipe.serves)
          stmt.setString(4, recipe.ingredients)
          stmt.setInt(5, recipe.cost)
          stmt.setLong(6, id)

          val updated = stmt.executeUpdate()
          if (updated > 0) {
            val updatedRecipe = getRecipeById(id)
            Ok(Json.obj(
              "message" -> "Recipe successfully updated!",
              "recipe" -> Json.arr(updatedRecipe)
            ))
          } else {
            NotFound(Json.obj("message" -> "No Recipe found"))
          }
        }
      }
    )
  }

  // DELETE /recipes/:id - 删除食谱
  def delete(id: Long) = Action {
    db.withConnection { conn =>
      val sql = "DELETE FROM recipes WHERE id = ?"
      val stmt = conn.prepareStatement(sql)
      stmt.setLong(1, id)
      val deleted = stmt.executeUpdate()

      if (deleted > 0) {
        Ok(Json.obj("message" -> "Recipe successfully removed!"))
      } else {
        NotFound(Json.obj("message" -> "No Recipe found"))
      }
    }
  }

  // 辅助方法：根据 ID 获取食谱
  private def getRecipeById(id: Long): JsValue = {
    db.withConnection { conn =>
      val sql = "SELECT * FROM recipes WHERE id = ?"
      val stmt = conn.prepareStatement(sql)
      stmt.setLong(1, id)
      val rs = stmt.executeQuery()

      if (rs.next()) {
        Json.obj(
          "id" -> rs.getLong("id"),
          "title" -> rs.getString("title"),
          "making_time" -> rs.getString("making_time"),
          "serves" -> rs.getString("serves"),
          "ingredients" -> rs.getString("ingredients"),
          "cost" -> rs.getString("cost"),
          "created_at" -> rs.getTimestamp("created_at").toString,
          "updated_at" -> rs.getTimestamp("updated_at").toString
        )
      } else {
        JsNull
      }
    }
  }
}