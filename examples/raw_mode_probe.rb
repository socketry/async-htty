# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "io/console"

unless STDIN.tty? && STDOUT.tty?
	warn "This program must be run in an interactive terminal."
	exit 1
end

original_state = `stty -g`.chomp

restore_terminal = proc do
	next if original_state.empty?
	system("stty", original_state, exception: false)
end

Signal.trap("TERM") do
	puts "\nReceived TERM, restoring terminal state..."
	restore_terminal.call
	exit 0
end

Signal.trap("INT") do
	puts "\nReceived INT, restoring terminal state..."
	restore_terminal.call
	exit 0
end

at_exit do
	restore_terminal.call
end

puts <<~TEXT
	Entering raw mode.
	PID: #{Process.pid}

	Controls:
	- Press `q` to exit normally.
	- Press Ctrl-C to send the raw byte 0x03; this script will exit and restore the terminal.
	- From another shell, run `kill -TERM #{Process.pid}` to test normal signal cleanup.
	- From another shell, run `kill -9 #{Process.pid}` to test abrupt termination.

	While raw mode is active, keypresses are printed immediately as bytes.
TEXT

STDIN.raw(min: 0, time: 1) do |input|
	loop do
		chunk = input.read_nonblock(32, exception: false)

		case chunk
		when :wait_readable, nil
			# Keep the process alive while waiting for external signals.
			next
		else
			bytes = chunk.bytes
			puts "read #{bytes.length} byte(s): #{bytes.map {|byte| format("0x%02X", byte)}.join(" ")}"

			break if chunk.include?("q")
			break if bytes.include?(3)
		end
	end
	puts "Leaving raw mode normally."
end