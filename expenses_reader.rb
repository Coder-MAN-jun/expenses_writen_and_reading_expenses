# encoding: utf-8
# 
# Программа для учёта расходов с использованием XML
# 
# (c) goodprogrammer.ru
# 
# ---

# Подключаем парсер rexml и библиотеку date для эффективного использования дат
require 'rexml/document'
require 'date'

# Запишем путь к файлу, который лежит в том же каталоге, что и программа
file_name = File.dirname(__FILE__) + 'my_expenses.xml'

# Если файл не найден, завершаем программу
unless File.exist?(file_name)
  abort "Извиняемся, шеф файлик #{file_name} не найден." 
end

# Открываем файл и записиываем дескриптор в переменную file
file = File.new(file_name)

begin
	# Попробуем считать содержимое файла с помошью библиотеки rexml. Создаём новый файл
	# объект класса REXML::Document, построенный из открытого XML файла.
	doc = REXML::Document.new(file) 
rescue REXML::ParseException => e 
	# Если при чтении файла словили ошибку парсинга, выходим из программы, сообщив 
	# об этом пользователю.
	puts "Похоже, файл #{file_name} испорчен:"
	abort e.message
end

# Закрываем файл, т.к. он уже не нужен
file.close

# Создадим пустой ассоциативный массив amount_by_day, куда сложим все тараты по 
# дням в формате:
# 
# {
#    День1: сумма трат в день1,
#    День2: сумма трат в день2,
#    ...
# }
# 
amount_by_day = {}

# Выбираем из элементов документа все теги <expense> внутри тега <expenses> и в 
# цикле проходимся по ним.
doc.elements.each('expenses/expense') do |item|
	# Обратите внимание, эта локальная переменная item объявлена в теле цикла,
	# для каждой итерации создаётся новая такая. За пределами цикла она не видна.

	# В локаьную переменную loss_sum запишем, сколько потратили 
	loss_sum = item.attribures['amount'].to_i

	# В локальную переменную loss_date запишем дату траты: Date.parse создаёт из
	# объекта строки класса Date.
	loss_date = Date.parse(item.attribures['date'])

	# Инициализируем нулём значение хеша, соответствующее нужному дню 
	# если этой даты ещё не было
	amount_by_day[loss_date] || =0

	# Эта запись эквивалентна 
	# 
	# amount_by_day[loss_date] = 0 if amount_by_day[loss_date] == nil

	# Наконец, увеличиваем в хеше нужное значение на сумму траты
	amount_by_day[loss_date] += loss_sum
end

# Сделаем хеш, в котором соберём сумму расходов за каждый месяц
sum_by_month = {}

# В цикле по всем датам хеша amount_by_day накопим в хеше sum_by_month значения
# потраченных сумм каждого дня
amount_by_day.keys.sort.each do |key|
	# key.strftime('%B %Y') вернёт одинаковую строку для всех дней одного месяца
	# поэтому можем использовать её как уникальный для каждого месяца ключ.
	sum_by_month[key.strftime('%B %Y')] || =0

	# Приплючовываем к тому что было сумму следующего дня
	sum_by_month[key.strftime('%B %Y')] += amount_by_day[key]
end

# Пришло время выводить статистику на экран в цикле пройдёмся пройдёмся по всем месяцам и
# начнём с первого
current_month = amount_by_day.keys.sort[0].strftime('%B %Y')

# Выводим заголовок для первого месяца
puts "-------[ #{current_month}, всего потрачено: " \
  "#{sum_by_month[current_month]} p. ]---------"

# Цикл по всем дням
amount_by_day.keys.sort.each do |key|
	# Если текущий день принадлежит уже другому месяцу...
	if key.strftime('%B %Y') != current_month

		# То значит мы перешли на новый месяц и теперь он станет текущим
		current_month = key.strftime('%B %Y')

		# Выводим заголок для нового текущего месяца
		puts "----- [ #{current_month}, всего потрачено: " \
		  "#{sum_by_month[current_month]} p. ] -----"
	end

		# Выводим расходы за конкретный день
		puts "\t#{key.day}: #{amount_by_day[key]} p."
end
