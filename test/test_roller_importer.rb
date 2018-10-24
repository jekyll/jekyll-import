require "helper"
require "htmlentities"

class TestRollerImporter < Test::Unit::TestCase
  should "clean slashes from slugs" do
    test_title = "blogs part 1/2"
    assert_equal("blogs-part-1-2", Importers::Roller.sluggify(test_title))
  end
  should "generate basic query" do
    select = "column"
    table = "table"
    assert_equal("SELECT column FROM table", Importers::Roller.gen_db_query(select, table, "", "", ""))
  end
  should "generate query multiple columns" do
    select = ["column1","column2"]
    table = "table"
    assert_equal("SELECT column1,column2 FROM table", Importers::Roller.gen_db_query(select, table, "", "", ""))
  end
  should "generate query with where clause" do
    select = "column"
    table = "table"
    where = "test = 'text'"
    assert_equal("SELECT column FROM table WHERE test = 'text'", Importers::Roller.gen_db_query(select, table, where, "", ""))
  end
  should "generate query with left join" do
    select = ["table1.column","table2.content"]
    table = "table1"
    join = ["table2 ON table1.condition = table2.test"]
    assert_equal("SELECT table1.column,table2.content FROM table1 LEFT JOIN table2 ON table1.condition = table2.test", Importers::Roller.gen_db_query(select, table, "", join, ""))
  end
  should "generate query with aliases" do
    select = ["table.column AS `foo`","table.column2 AS `bar`"]
    table = "table AS `table`"
    assert_equal("SELECT table.column AS `foo`,table.column2 AS `bar` FROM table AS `table`", Importers::Roller.gen_db_query(select, table, "", "", ""))
  end
  should "generate query with multiple where clauses joins and aliases" do
    select = ["table1.foo AS `foo`","table1.bar AS `bar`","table2.foo AS `foo2`","table3.bar AS `bar2`"]
    table = "table1 AS `table1`"
    where = ["table1.test1 = 'text1'","table1.test2 = 'text2'"]
    join = ["table2 AS `table2` ON table1.condition = table2.test","table3 AS `table3` ON table1.condition = table3.test"]
    assert_equal("SELECT table1.foo AS `foo`,table1.bar AS `bar`,table2.foo AS `foo2`,table3.bar AS `bar2` FROM table1 AS `table1` LEFT JOIN table2 AS `table2` ON table1.condition = table2.test LEFT JOIN table3 AS `table3` ON table1.condition = table3.test WHERE table1.test1 = 'text1' AND table1.test2 = 'text2'", Importers::Roller.gen_db_query(select, table, where, join, ""))
  end
  should "generate query with multiple where clauses either or joins and aliases" do
    select = ["table1.foo AS `foo`","table1.bar AS `bar`","table2.foo AS `foo2`","table3.bar AS `bar2`"]
    table = "table1 AS `table1`"
    where = ["table1.test1 = 'text1'","table1.test2 = 'text2'"]
    join = ["table2 AS `table2` ON table1.condition = table2.test","table3 AS `table3` ON table1.condition = table3.test"]
    assert_equal("SELECT table1.foo AS `foo`,table1.bar AS `bar`,table2.foo AS `foo2`,table3.bar AS `bar2` FROM table1 AS `table1` LEFT JOIN table2 AS `table2` ON table1.condition = table2.test LEFT JOIN table3 AS `table3` ON table1.condition = table3.test WHERE table1.test1 = 'text1' OR table1.test2 = 'text2'", Importers::Roller.gen_db_query(select, table, where, join, "OR"))
  end
end
