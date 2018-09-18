module DateFilter
    MONTHS = %w(Janeiro Fevereiro Março Abril Maio Junho Julho Agosto Setembro Outubro Novembro Dezembro)

    def date_long(input)
      dia = input.strftime("%d")
      mes = MONTHS[input.strftime("%m").to_i - 1]
      ano = input.strftime("%Y")
      dia+' de '+mes+' de '+ano
    end

    def date_time_long(input)
      self.date_long(input) +' as '+ input.strftime("%H:%M")+'h'
    end
end

  Liquid::Template.register_filter(DateFilter)