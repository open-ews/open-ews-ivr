module PumiLao
  class DataSource
    class << self
      def provinces
        @provinces ||= Collection.new(
          [
            Province.new(id: "14", name_en: "Salavan", name_lo: "ສາລະວັນ", iso3166_2: "LA-SL"),
            Province.new(id: "16", name_en: "Champasak", name_lo: "ຈຳປາສັກ", iso3166_2: "LA-CH"),
            Province.new(id: "17", name_en: "Attapeu", name_lo: "ອັດຕະປື", iso3166_2: "LA-AT")
          ]
        )
      end

      def districts
        @districts ||= Collection.new(
          [
            # Salavan
            District.new(id: "1401", name_en: "Saravane", name_lo: "ສາລະວັນ", province: provinces.find_by!(id: "14")),
            District.new(id: "1402", name_en: "Ta Oy", name_lo: "ຕະໂອ້ຍ", province: provinces.find_by!(id: "14")),
            District.new(id: "1403", name_en: "Toumlane", name_lo: "ຕຸ້ມລານ", province: provinces.find_by!(id: "14")),
            District.new(id: "1404", name_en: "Lakhonepheng", name_lo: "ລະຄອນເພັງ", province: provinces.find_by!(id: "14")),
            District.new(id: "1405", name_en: "Vapy", name_lo: "ວາປີ", province: provinces.find_by!(id: "14")),
            District.new(id: "1406", name_en: "Khongsedone", name_lo: "ຄົງເຊໂດນ", province: provinces.find_by!(id: "14")),
            District.new(id: "1407", name_en: "Lao Ngam", name_lo: "ເລົ່າງາມ", province: provinces.find_by!(id: "14")),
            District.new(id: "1408", name_en: "Sa Mouay", name_lo: "ສະມ້ວຍ", province: provinces.find_by!(id: "14")),
            # Champasak
            District.new(id: "1601", name_en: "Pakse", name_lo: "ປາກເຊ", province: provinces.find_by!(id: "16")),
            District.new(id: "1602", name_en: "Sanasomboun", name_lo: "ຊະນະສົມບູນ", province: provinces.find_by!(id: "16")),
            District.new(id: "1603", name_en: "Batiengchaleunsouk", name_lo: "ບາຈຽງຈະເລີນສຸກ", province: provinces.find_by!(id: "16")),
            District.new(id: "1604", name_en: "Paksong", name_lo: "ປາກຊ່ອງ", province: provinces.find_by!(id: "16")),
            District.new(id: "1605", name_en: "Pathouphone", name_lo: "ປະທຸມພອນ", province: provinces.find_by!(id: "16")),
            District.new(id: "1606", name_en: "Phonthong", name_lo: "ໂພນທອງ", province: provinces.find_by!(id: "16")),
            District.new(id: "1607", name_en: "Champassack", name_lo: "ຈຳປາສັກ", province: provinces.find_by!(id: "16")),
            District.new(id: "1608", name_en: "Soukhoumma", name_lo: "ສຸຂຸມາ", province: provinces.find_by!(id: "16")),
            District.new(id: "1609", name_en: "Mounlapamok", name_lo: "ມູນລະປະໂມກ", province: provinces.find_by!(id: "16")),
            District.new(id: "1610", name_en: "Khong", name_lo: "ໂຂງ", province: provinces.find_by!(id: "16")),
            # Attapeu
            District.new(id: "1701", name_en: "Saysetha", name_lo: "ໄຊເຊດຖາ", province: provinces.find_by!(id: "17")),
            District.new(id: "1702", name_en: "Samakkhixay", name_lo: "ສາມັກຄີໄຊ", province: provinces.find_by!(id: "17")),
            District.new(id: "1703", name_en: "Sanamxay", name_lo: "ສະໜາມໄຊ", province: provinces.find_by!(id: "17")),
            District.new(id: "1704", name_en: "Phouvong", name_lo: "ພູວົງ", province: provinces.find_by!(id: "17"))
          ]
        )
      end
    end
  end
end
