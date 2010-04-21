require "test/unit"
require "taskmaster"

class TestTaskmaster < Test::Unit::TestCase

  def setup

    ###
    # Setup Class

    @tm = Taskmaster

    ###
    # Setup Clearing Tasks & Output

    @clear = Proc.new{
      @tm::TASKS.clear
      @@output = []
    }

    ###
    # Setup Recipe that clears Output to always make same call

    @task = Proc.new{
      @clear.call
      @tm.cookbook do
        task :sandwich, :meat, :bread do
          puts "making a sammich!"
        end
        task :meat, :clean do
          puts "preparing the meat"
        end
        task :bread, :clean do
          puts "preparing the bread"
        end
        task :clean, :mop, :handwash do
          puts "cleaning"
        end
        task :handwash do
          puts "washing hands"
        end
        task :mop do
          puts "mopping!"
        end
      end
    }

    ###
    # Collect Output

    def @tm.puts arg
      @@output ||= []
      @@output << arg if arg
    end

  end

  ###
  # Test Cookbook

  def test_cookbook_evals_block
    actual       = @tm.cookbook { self::VERSION }
    expected     = '1.0.0'
    assert_equal expected, actual
  end

  ###
  # Test Task

  def test_cookbook_task_creates_only_one_task
    @clear.call
    @tm.cookbook do
      task :only_one do
        'one'
      end
    end
    assert_equal 1, @tm::TASKS.length
  end

  def test_cookbook_task_creates_three_tasks
    @clear.call
    @tm.cookbook do
      task :one, :two do
        'one'
      end
      task :two, :three do
        'two'
      end
      task :three do
        'three'
      end
    end
    assert_equal 3, @tm::TASKS.length
  end
  
  def test_cookbook_task_raises_on_missing_dependency
    assert_raise StandardError do
      @tm.cookbook do
        task :one, :missing do
          'one'
        end
        task :two, :broken do
          'two'
        end
      end
    end
  end

  def test_task_sets_no_task_dependency
    @task.call
    actual       = @tm::TASKS[:mop][:deps]
    expected     = []
    assert_equal expected, actual
  end

  def test_recipe_sets_single_task_dependency
    @task.call
    actual       = @tm::TASKS[:meat][:deps]
    expected     = [:clean]
    assert_equal expected, actual
  end

  def test_recipe_sets_multiple_task_dependencies
    @task.call
    actual       = @tm::TASKS[:sandwich][:deps]
    expected     = [:meat, :bread]
    assert_equal expected, actual
  end

  def test_block_response_from_tasks
    @task.call
    @tm::TASKS[:mop][:labor].call
    actual       = @@output
    expected     = ["mopping!"]
    assert_equal expected, actual
  end

  ###
  # Test Execute

  def test_execute_task_with_no_dependencies_is_met
    @task.call
    @tm.execute :mop
    assert @@output.include?("mopping!")
  end

  def test_execute_task_with_no_dependencies_does_labor
    @task.call
    @tm.execute :mop
    actual       = @@output
    expected     = ["** Executing task 'mop'", "mopping!", "** done"]
    assert_equal expected, actual
  end

  def test_execute_task_with_with_multiple_dependencies_does_labor
    @task.call
    @tm.execute [:mop, :handwash, :clean]
    actual = @@output
    expected = ["** Executing task 'mop'", "mopping!", "** Executing task 'handwash'", "washing hands", "** Executing task 'clean'", "cleaning", "** done"]
    assert_equal expected, actual
  end

  ###
  # Test Run

  def test_task_does_not_exist
    assert_raise StandardError do
      @tm.run :badTask
    end
  end

  def test_run_executes_single_recipe
    @task.call
    @tm.run :mop
    assert_equal @@output, [  "** Executing task 'mop'"       ,
                              "mopping!"                      ,
                              "** done"                       ]
  end

  def test_run_executes_single_recipe_with_dependencies
    @task.call
    @tm.run(@tm.run_list_for :clean)
    assert_equal @@output, [  "** Executing task 'mop'"       ,
                              "mopping!"                      ,
                              "** Executing task 'handwash'"  , 
                              "washing hands"                 ,
                              "** Executing task 'clean'"     ,
                              "cleaning"                      ,
                              "** done"                       ]
  end

  def test_run_task_builds_sandwich_and_outputs_correctly
    @task.call
    @tm.run( @tm.run_list_for(:sandwich))
    assert_equal @@output, [  "** Executing task 'mop'"       ,
                              "mopping!"                      ,
                              "** Executing task 'handwash'"  ,
                              "washing hands"                 ,
                              "** Executing task 'clean'"     ,
                              "cleaning"                      ,
                              "** Executing task 'meat'"      ,
                              "preparing the meat"            ,
                              "** Executing task 'bread'"     ,
                              "preparing the bread"           ,
                              "** Executing task 'sandwich'"  ,
                              "making a sammich!"             ,
                              "** done"                       ]
  end

  ###
  # Test Run List For
  
  def test_run_list_for_large_dependencies
    @task.call
    expected     = [:mop, :handwash, :clean, :meat, :bread, :sandwich]
    actual       = @tm.run_list_for(:sandwich)
    assert_equal expected, actual
  end

  def test_run_list_for_small_dependencies
    @task.call
    expected     = [:mop, :handwash, :clean]
    actual       = @tm.run_list_for(:clean)
    assert_equal expected, actual
  end
  
  def test_run_list_for_invalid_task
    @task.call
    assert_raise StandardError do 
      @tm.run_list_for(:invalid)
    end
  end
  
  def test_run_list_for_and_call_run
    @task.call
    list1 = @tm.run_list_for(:sandwich)
    list2 = @tm.run_list_for(:clean)
    @tm.run(list1, list2)
    assert_equal @@output, [  "** Executing task 'mop'"       ,
                              "mopping!"                      ,
                              "** Executing task 'handwash'"  ,
                              "washing hands"                 ,
                              "** Executing task 'clean'"     ,
                              "cleaning"                      ,
                              "** Executing task 'meat'"      ,
                              "preparing the meat"            ,
                              "** Executing task 'bread'"     ,
                              "preparing the bread"           ,
                              "** Executing task 'sandwich'"  ,
                              "making a sammich!"             ,
                              "** done"                       ,
                              "** Executing task 'mop'"       ,
                              "mopping!"                      ,
                              "** Executing task 'handwash'"  ,
                              "washing hands"                 ,
                              "** Executing task 'clean'"     ,
                              "cleaning"                      ,
                              "** done"                       ]
  end

end