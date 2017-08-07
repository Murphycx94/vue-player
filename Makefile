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

push: readme
	git add .
	git commit -m 'update'
	git push



build: pull
	npm run build
	make push
