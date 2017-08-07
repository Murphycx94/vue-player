all:
	@echo "========================================"
	@echo "========================================"
	@echo "====                               ====="
	@echo "====                               ====="
	@echo "====                               ====="
	@echo "========================================"
	@echo "========================================"

pull:
	git pull

readme:
	cp -f -a README.md ./dist

push:
	git add .
	git commit -m 'update'
	git push
	make readme



build: pull
	npm run build
	make readme
	make push
