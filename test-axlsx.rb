#!/usr/bin/env ruby

require 'axlsx'

p = Axlsx::Package.new
p.workbook.add_worksheet do |sheet|
  color = sheet.styles.add_style bg_color: "FF0000" 
  sheet.add_row ['Cell with visible comment'], style: color
end
p.serialize('worksheet.xlsx')
