
all: $(OBJECTS) $(OUTPUT)
%.o: %.c
	@echo "  COMPILE   $<"
	@$(CC) $(CFLAGS) -c -o $@ $<
%.o: %.cpp
	@echo "  COMPILE   $<"
	@$(CPP) $(CPPFLAGS) -c -o $@ $<
%.o: %.s
	@echo "  ASSEMBLE  $<"
	@$(CC) $(CFLAGS) $(SFLAGS) -c -o $@ $<
%.o: %.S
	@echo "  ASSEMBLE  $<"
	@$(CC) $(CFLAGS) $(SFLAGS) -c -o $@ $<
%.elf: $(OBJECTS)
	@echo "  LINK      $<"
	@$(CC) $(OBJECTS) $(LDFLAGS) -o $@
%.a: $(OBJECTS)
	@echo "  ARCHIVE   $@"
	@$(AR) rcs "$@" $(OBJECTS)
clean:
	@echo "  CLEAN"
	@$(RM) $(OUTPUT) $(OBJECTS)

