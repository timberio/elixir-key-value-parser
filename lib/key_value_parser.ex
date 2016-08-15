defmodule KeyValueParser do
  @moduledoc """
  This module contains functions to parse key value pairs.
  """

  defmodule InvalidTokenSyntax do
    @moduledoc """
    Exception raised when a token does not contain an equals delimiter. (: or =)
    """
    defexception message: "Token is invalid, it does not contain an equals delimiter, : or ="

    def exception(opts \\ []) do
      term = Keyword.fetch!(opts, :term)
      %InvalidTokenSyntax{
        message: "The #{inspect(term)} term does not contain an equals delimiter, : or ="
      }
    end
  end

  @type t :: Keyword.t

  @doc ~S"""
  Splits a string into a Keyword.

  This function splits the given `string` into a list of key value pairs
  as outlined in the Keyword module.

  ## Examples
      iex> KeyValueParser.split("name:\"Timber Technologies\" domain:timber.io awesome:true")
      [name: "Timber Technologies", domain: "timber.io", awesome: true]
  """
  @spec parse(String.t) :: t
  def parse(input) do
    do_split(String.trim_leading(input, " "), "", Keyword.new, nil)
  end

  # The following code was taken from the OptionParser module and
  # slightly tweaked for this specific use case.

  # If we have an escaped quote, simply remove the escape
  defp do_split(<<?\\, quote, t::binary>>, buffer, acc, quote),
    do: do_split(t, <<buffer::binary, quote>>, acc, quote)

  # If we have a quote and we were not in a quote, start one
  defp do_split(<<quote, t::binary>>, buffer, acc, nil) when quote in [?", ?'],
    do: do_split(t, buffer, acc, quote)

  # If we have a quote and we were inside it, close it
  defp do_split(<<quote, t::binary>>, buffer, acc, quote),
    do: do_split(t, buffer, acc, nil)

  # If we have an escaped quote/space, simply remove the escape as long as we are not inside a quote
  defp do_split(<<?\\, h, t::binary>>, buffer, acc, nil) when h in [?\s, ?', ?"],
    do: do_split(t, <<buffer::binary, h>>, acc, nil)

  # If we have space and we are outside of a quote, start new segment
  defp do_split(<<?\s, t::binary>>, buffer, acc, nil),
    do: do_split(String.trim_leading(t, " "), "", Keyword.merge(to_keyword(buffer), acc), nil)

  # All other characters are moved to buffer
  defp do_split(<<h, t::binary>>, buffer, acc, quote) do
    do_split(t, <<buffer::binary, h>>, acc, quote)
  end

  # Finish the string expecting a nil marker
  defp do_split(<<>>, "", acc, nil),
    do: acc

  defp do_split(<<>>, buffer, acc, nil),
    do: Enum.reverse(Keyword.merge(to_keyword(buffer), acc))

  # Otherwise raise
  defp do_split(<<>>, _, _acc, marker) do
    raise "argv string did not terminate properly, a #{<<marker>>} was opened but never closed"
  end

  defp to_keyword(term) do
    parts = String.split(term,  [":", "="], parts: 2)
    if length(parts) == 2 do
      [key, value] = parts
      Keyword.new(["#{key}": value])
    else
      raise InvalidTokenSyntax, term: term
    end
  end
end