require 'fofa_http'

module Fofa

  VERSION = "0.0.2"

  class Exploit
    attr_reader :info
    def initialize(info = {})
      @info = info
    end

    def excute_scansteps(params)
      oper = 'AND'
      @info['ScanSteps'].each{|step|
        if step.kind_of?(String)
          oper = step
        else
          if execute_step(step, params)
            if oper=='OR'
              return true
            end
          else
            if oper=='AND'
              return false #任何一个测试请求失败都返回FALSE
            end
          end
        end
      }
      true
    end

    def vulnerable(hostinfo)
      excute_scansteps(hostinfo) if @info['ScanSteps']
    end

    def exploit(hostinfo)
      false
    end

    private

    def execute_step(step, hostinfo)
      puts step['Loginfo'] if step['Loginfo']
      response = make_request(hostinfo, step['Request'])
      check_response(response, step['ResponseTest'])
    end

    def make_request(hostinfo, request)
      response = Fofa::HttpRequest.row_http(hostinfo, request)
      response
    end

    def check_response(response, test)
      check_one(response, test)
    end

    def check_one(response, test)
      if test[:type]=='item'
        execute_item response, test
      else
        execute_group response, test
      end
    end

    def execute_group(response, test)
      case test[:operation]
        when 'AND'
          test[:checks].each{|t|
            return false unless check_one(response, t)
          }
          return true
        when 'OR'
          test[:checks].each{|t|
            return true if check_one(response, t)
          }
          return false
      end
    end

    def execute_item(response, test)
      case test[:varibale]
        when '$code'
          test_int(response[:code].to_i, test[:operation], test[:value].to_i)
        when '$body'
          test_string(response[:utf8html], test[:operation], test[:value])
        when '$head'
          test_string(response[:header], test[:operation], test[:value])
      end
    end

    def test_string(value, operation, expect_value)
      case operation
        when 'start_with'
          value && value.start_with?(expect_value)
        when 'end_with'
          value && value.end_with?(expect_value)
        when 'contains'
          value && value.include?(expect_value)
        when 'regex'
          value && value =~ expect_value
      end
    end

    def test_int(value, operation, expect_value)
      case operation
        when '=='
          value == expect_value
        when '!='
          value != expect_value
        when '>'
          value > expect_value
        when '<'
          value < expect_value
        when '>='
          value >= expect_value
        when '<='
          value <= expect_value
      end
    end
  end


end