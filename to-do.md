# To-do

Uma lista organizada dos próximos feitiços técnicos do `folderstamp`.

## Próximas prioridades

- [ ] Implementar flag `--hash` para controlar quando o CID deve ser calculado.
- [ ] Registrar a data/hora exata no fim de cada snapshot.
- [ ] Adicionar opção para registrar o número do bloco Ethereum mais recente no momento do stamp.

## Modos de listagem

- [ ] Criar modo simples `.ls`, com rotação `.ls1`, `.ls2` etc.
- [ ] Criar `.folderstamp.listed` para evitar listar novamente arquivos já snapshotados anteriormente.
- [ ] Avaliar integração futura com uma biblioteca de nomes incrementais/untitled para evitar sobrescrever arquivos.

## Desktop e ambiente gráfico

- [ ] Quando o stamp for feito no Desktop, detectar o ambiente gráfico quando possível.
- [ ] Em Cinnamon, registrar o wallpaper atual com:
  ```sh
  gsettings get org.cinnamon.desktop.background picture-uri | tr -d "'"
  ```
- [ ] Pesquisar como registrar posições e ícones de itens no Desktop por ambiente gráfico.
- [ ] Fazer fallback silencioso quando não houver desktop environment detectado.

## Recursividade e escopo

- [ ] No modo recursivo, registrar também metadados das pastas, não apenas dos arquivos.
- [ ] Adicionar opção para limitar profundidade de recursão.
- [ ] Adicionar opção para escolher um número customizado para `.folderstamp`, recusando números já existentes.

## Portabilidade, integridade e testes

- [ ] Validar a execução em Termux real (Android/Bionic), incluindo execução por shell interativo e não interativo.
- [ ] Testar o instalador em Termux com e sem uma instalação anterior.
- [ ] Adicionar testes automatizados para nomes com espaços, tabs, quebras de linha, Unicode e diretórios vazios.
- [ ] Testar concorrência entre duas chamadas simultâneas de `save`.
- [ ] Verificar comportamento em sistemas de arquivos sem suporte confiável a renomeação atômica.
- [ ] Validar o fallback CIDv0 contra Kubo em arquivos vazios, pequenos e acima do limite de chunking.
- [ ] Testar assets e instalação de ferramentas externas por arquitetura e libc antes de habilitar autodownload em cada plataforma.
- [ ] Migrar do CLI Iroh legado v0.28.1 para uma interface atual de Iroh assim que Releases oficiais voltarem a publicar um CLI de blobs.
- [ ] Expandir a detecção de package managers além de `apt`, `dnf`, `pacman`, `apk`, `zypper`, `pkg` e Cygwin setup.

## Controle de versão alternativo

- [ ] Melhorar suporte ao Gitoxide para extrair branch/remotes sem depender do Git clássico.
- [ ] Expandir suporte Pijul para registrar remotes, identidade do repositório e mudanças pendentes.
- [ ] Adicionar testes simulando ambientes com apenas `git`, apenas `gix`, apenas `pijul` e nenhum VCS instalado.

## Plataformas adicionais

- [ ] Testar o instalador em macOS real com e sem Homebrew.
- [ ] Testar comandos BSD com `pkg` e `pkg_add` em shells não-GNU.
- [ ] Documentar o que é possível automatizar em Zircon/Fuchsia sem fingir universalidade fake.

## Documentação

- [x] Criar `README.md` com instalação, uso, exemplos e troubleshooting.
- [x] Documentar diferenças e limitações conhecidas de Termux, especialmente a incompatibilidade presumida de binários Linux/glibc com Android/Bionic.
- [x] Documentar as limitações do fallback CIDv0 single-block e do matcher `.folderstampignore`.
