#
# Author:: James Massardo (<james@dxrf.com>)
# Copyright:: Copyright (c) James Massardo
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'date'

module MaintenanceWindow
  module InMaintWindow
    def in_maint_window
      interval = node['maint_window']['interval']
      if interval == 'daily'
        daily_window
      elsif interval == 'weekly'
        weekly_window
      elsif interval == 'monthly'
        monthly_window
      elsif interval == 'offset'
        offset_window
      else
        false
      end
    end

    def daily_window
      time_check
    end

    def weekly_window
      # check if it's the right day of the week
      # if so, call time_check
      # if not, return false
      current_date = DateTime.now

      week_day = node['maint_window']['week_day']
      case week_day
      when 'Sunday'
        time_check if current_date.sunday?
      when 'Monday'
        time_check if current_date.monday?
      when 'Tuesday'
        time_check if current_date.tuesday?
      when 'Wednesday'
        time_check if current_date.wednesday?
      when 'Thursday'
        time_check if current_date.thursday?
      when 'Friday'
        time_check if current_date.friday?
      when 'Saturday'
        time_check if current_date.saturday?
      else
        # Something's not right so bailing out
        false
      end
    end

    def monthly_window
      # check to make sure it's the right day of the month
      # if so, call time_check
      # if not, return false
      current_date = DateTime.now
      day = node['maint_window']['day']
      if current_date.day == day.to_i
        time_check
      else
        false
      end
    end

    def offset_window
      # Patch Tuesday offset
      # Check to see how many days it is past the 2nd Tuesday
      # of the month.
      # if so, call time_check
      # if not, return false
      current_date = DateTime.now
      patch_tuesday = nth_wday(2, 2, current_date.month, current_date.year).to_date
      offset = node['maint_window']['offset']
      mw_date = patch_tuesday + Rational(offset, 1)
      if mw_date.day == current_date.day
        time_check
      else
        false
      end
    end

    def time_check
      current_date = DateTime.now
      start_time = node['maint_window']['start_time']
      duration = node['maint_window']['duration']
      mw_start = DateTime.new(current_date.year, current_date.month, current_date.day, start_time.split(':')[0].to_i, start_time.split(':')[1].to_i, 0, current_date.zone)
      mw_end = mw_start + Rational(duration, 24)

      if mw_start < current_date && current_date < mw_end
        true
      else
        false
      end
    end

    def nth_wday(n, wday, month, year)
      if (!n.between? 1, 5) || (!wday.between? 0, 6) || (!month.between? 1, 12)
        raise ArgumentError, 'Invalid day or date'
      end

      t = Time.local year, month, 1
      first = t.wday

      if first == wday
        fwd = 1
      elsif first < wday
        fwd = wday - first + 1
      elsif first > wday
        fwd = (wday + 7) - first + 1
      end

      target = fwd + (n - 1) * 7

      begin
        t2 = Time.local year, month, target
      rescue ArgumentError
        return nil
      end

      t2 if t2.mday == target
    end
  end
end

Chef::Recipe.include(MaintenanceWindow::InMaintWindow)
Chef::Resource.include(MaintenanceWindow::InMaintWindow)
Chef::Provider.include(MaintenanceWindow::InMaintWindow)
